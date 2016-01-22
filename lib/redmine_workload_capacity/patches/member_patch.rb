module RedmineWorkloadCapacity
	module Patches
		module  MemberPatch
			def self.included(base) # :nodoc:
		        #base.extend(ClassMethods)

		        base.send(:include, MemberInstanceMethods)

		        base.class_eval do
		          unloadable # Send unloadable so it will not be unloaded in development
		          after_save :wl_reload
		        end
		    end
		end

		module MemberInstanceMethods
			include WlLogic
			include WlMember

			def wl_reload
				self.project.wl_reload
			end

			def wl_member?
				return WlUser.wl_member?(self)
			end

			# Returns the project allocation object
			def wl_project_allocation
				return WlProjectAllocation.find_by(user_id: self.user_id, wl_project_window_id: self.project.wl_project_window.id)
			end

			# Returns true if the associated user has a project allocation defined
			def wl_project_allocation?
				return self.wl_project_allocation != nil
				#return true
			end

			# Gives the allocation table for a member within a project, during his project window(s)
			def wl_table_allocation
				return WlLogic.generate_allocations_table_member(self)
			end

			def wl_project_allocation_between(from, to)
				time_period = from..to
				#table_allocs = self.wl_table_allocation
				table_periods = self.wl_table_allocation#table_allocs

				table_periods.each_with_index do |t|
					return t[:percent_alloc] if (t[:start_date]..t[:end_date]).overlaps?(time_period) && from >= t[:start_date] && to <= t[:end_date]
				end
				return 0
			end

			def wl_sum_alloc_on_working_days(from_date, to_date)
	
				working_days = self.user.working_days_count(from_date, to_date)
  	 			p_allocation = self.wl_project_allocation_between(from_date, to_date)
  	 			return p_allocation*working_days
								
			end

			# Returns the total cross project allocation table, bound to current project window
			def wl_global_table_allocation
				#user_table_alloc = self.user.wl_table_allocation

				wl_custom_project_windows = WlCustomProjectWindow.where(user_id: self.user.id, wl_project_window_id: self.project.wl_project_window)

				user_project_window = self.project.wl_project_window

				if wl_custom_project_windows.empty?
					windows = [user_project_window]
				else
					windows = wl_custom_project_windows.to_a
				end

				allocs = []

				user_table_alloc = self.user.wl_table_allocation

				user_table_alloc.each do |alloc|
					windows.each do |window|
						if alloc[:start_date] >= window[:start_date] && alloc[:end_date] <= window[:end_date]
							allocs << alloc
						end
					end
				end

				return allocs
			end

			# Returns the total remaining cross project allocation table, excluding current project allocations, bound to current project window
			def wl_remaining_table_allocation
				project_alloc = self.wl_table_allocation
				total_alloc = self.wl_global_table_allocation
				output = total_alloc#self.wl_global_table_allocation

				project_alloc.each do |e|
					period = e[:start_date]..e[:end_date]
					total_alloc.each_with_index do |ta, i|
						ta_period = ta[:start_date]..ta[:end_date]
						if period.overlaps?(ta_period)
							total = (ta[:percent_alloc] - e[:percent_alloc])
							total = 100 if total > 100
							output[i][:percent_alloc] = 100 - total
						end
					end
				end

				return output
			end

			# Generates a table of the various allocations of the member (project, custom) within the project
			# Gets default project allocation + all custom allocations + all custom project windows set
			def wl_member_allocations_extract
				project_window = self.project.wl_project_window
				hsh = {}
				project_alloc = self.wl_project_allocation

				if project_alloc
					hsh[:project_id] = self.project.id
					hsh[:default_alloc] = project_alloc
					hsh[:custom_allocs] = []

					custom_allocs = WlCustomAllocation.where(user_id: self.user_id, wl_project_window_id: project_window.id)
					
					custom_allocs.find_each do |alloc|
						hsh[:custom_allocs] << alloc
					end

					hsh[:custom_project_windows] = WlCustomProjectWindow.where(user_id: self.user.id, wl_project_window_id: self.project.wl_project_window)
				end
				return hsh
			end


			#--------------use for wl_graph --------------------#
			# Returns the total remaining cross project allocation table, INcluding current project allocations, bound to current project window
			def gr_calcul_alloc(start_period, end_period, granularity, attribut)
				entry_datas = []

				if attribut == 0
					total_alloc = self.wl_table_allocation	
				else
					total_alloc = self.wl_global_table_allocation	
				end

				period = start_period..end_period
				current_day = start_period

				while current_day <= end_period
					data_result = 0
					case granularity #integer
					when 1 # weekly
						end_recc_date = current_day.end_of_week
						end_recc_date = end_period if end_recc_date > end_period

						data_result= self.average_for_period(total_alloc, current_day, end_recc_date, attribut)	
						current_day = end_recc_date+1 
										
					when 2 # monthly
						end_recc_date = current_day.end_of_month
						end_recc_date = end_period if end_recc_date > end_period
						data_result= self.average_for_period(total_alloc, current_day, end_recc_date, attribut)
						current_day = end_recc_date+1 
					when 3 # quarterly
						end_recc_date = current_day.end_of_quarter
						end_recc_date = end_period if end_recc_date > end_period
						data_result= self.average_for_period(total_alloc, current_day, end_recc_date, attribut)
						current_day = end_recc_date+1 
					when 4 # yearly
						end_recc_date = current_day.end_of_year
						end_recc_date = end_period if end_recc_date > end_period
						data_result= self.average_for_period(total_alloc, current_day, end_recc_date, attribut)
						current_day = end_recc_date+1 
					else #when 0 - daily
						data_result= self.average_for_period(total_alloc, current_day, current_day, attribut)
						current_day = current_day+1
					end
					entry_datas << data_result	
				end

				return entry_datas
			end

			def average_for_period(total_alloc, current_day, end_recc_date, attribut)
				output = 0
				nb_increment = 0
				while current_day <= end_recc_date
					total_alloc.each_with_index do |ta, i|
						if current_day.between?(ta[:start_date], ta[:end_date])
							case attribut #integer
# project_allocation: 0, total_allocation: 1, remaining_allocation: 2, logged_time: 3, check_ratio: 4#
							when 0 #project_allocation
								output += (ta[:percent_alloc])
							when 1 #total_allocation
								output += (ta[:percent_alloc])
							when 2 #remaining_allocation
								total = (ta[:percent_alloc])
								total = 100 if total > 100
								output += 100 - total
							else
								#other attribut
							end

							nb_increment = nb_increment+1
						end
					end

					current_day = current_day+1
				end #current_day = end_recc_date => end of the week
				unless nb_increment == 0
					return (output/nb_increment).round(2)	
				else
					return output
				end	
			end

			def convert_table_alloc_to_hours(table_data)
				table_result = []
				actual_wwhours = self.user.actual_weekly_working_hours
				table_result = table_data.map{|alloc| alloc*actual_wwhours/100}
				return table_result
			end


		end
	end
end

unless Member.included_modules.include?(RedmineWorkloadCapacity::Patches::MemberPatch)
  Member.send(:include, RedmineWorkloadCapacity::Patches::MemberPatch)
end