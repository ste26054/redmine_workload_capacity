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
			def gr_calcul_alloc(start_period, end_period, granularity, attribut, category_operation)
				entry_datas = []
				leave_table = []

				if attribut == 0  #project allocation
					alloc_table = self.wl_table_allocation	
				elsif attribut == 5 #real_allocation
					alloc_table = self.wl_table_allocation	
					leave_project_id = RedmineLeavesHolidays::Setting.defaults_settings(:default_project_id)
					leave_table = self.user.get_logged_time(Project.find(leave_project_id), start_period, end_period)
				else# 1: total_allocation or 2: remaining allocation
					alloc_table = self.wl_global_table_allocation	
				end

				period = start_period..end_period
				current_day = start_period

				while current_day <= end_period
					data_result = 0
					case granularity #integer
					when 1 # weekly
						end_recc_date = current_day.end_of_week
						end_recc_date = end_period if end_recc_date > end_period

						data_result= self.average_for_period(alloc_table, leave_table, current_day, end_recc_date, attribut, category_operation)	
						current_day = end_recc_date+1 
										
					when 2 # monthly
						end_recc_date = current_day.end_of_month
						end_recc_date = end_period if end_recc_date > end_period
						data_result= self.average_for_period(alloc_table, leave_table, current_day, end_recc_date, attribut, category_operation)
						current_day = end_recc_date+1 
					when 3 # quarterly
						end_recc_date = current_day.end_of_quarter
						end_recc_date = end_period if end_recc_date > end_period
						data_result= self.average_for_period(alloc_table, leave_table, current_day, end_recc_date, attribut, category_operation)
						current_day = end_recc_date+1 
					when 4 # yearly
						end_recc_date = current_day.end_of_year
						end_recc_date = end_period if end_recc_date > end_period
						data_result= self.average_for_period(alloc_table, leave_table, current_day, end_recc_date, attribut, category_operation)
						current_day = end_recc_date+1 
					else #when 0 - daily
						category_operation = 0 # no need to do a average
						data_result= self.average_for_period(alloc_table, leave_table, current_day, current_day, attribut, category_operation)
						current_day = current_day+1
					end
					entry_datas << data_result	
				end

				return entry_datas
			end

			def average_for_period(alloc_table, leave_table, current_day, end_recc_date, attribut, category_operation)
				output = 0
				nb_increment = 0

				actual_dailyhours = 0
				overtime_table =[]
				if attribut == 5
					actual_dailyhours = (self.user.actual_weekly_working_hours/5).round(2)	
					overtime_table =  WlUserOvertime.where(user_id: self.user_id, wl_project_window_id: self.project.wl_project_window.id)
				end

				while current_day <= end_recc_date
					alloc_table.each_with_index do |ta, i|
						if current_day.between?(ta[:start_date], ta[:end_date])
							case attribut #integer
				# project_allocation: 0, total_allocation: 1, remaining_allocation: 2, logged_time: 3, check_ratio: 4, real_allocation: 5#
							when 0 #project_allocation
								output += (ta[:percent_alloc])
							when 1 #total_allocation
								output += (ta[:percent_alloc])
							when 2 #remaining_allocation
								total = (ta[:percent_alloc])
								total = 100 if total > 100
								output += 100 - total
							when 5 #real_allocation
								result_alloc = ta[:percent_alloc]

								#__bank_holiday?
								if self.user.holiday_date_for_user(current_day)
									result_alloc = 0
								else

									#__leave_holiday?
									leave_hours = leave_table[current_day]
									unless leave_hours.nil? 
										if leave_hours.round(2) == actual_dailyhours #fullday leave
											result_alloc = 0
										else # halfday
											result_alloc = (ta[:percent_alloc])/2 
										end
									end
									if current_day.cwday == 6 || current_day.cwday == 7
										result_alloc = 0
									end
								end

								#__overtime?
								unless overtime_table.empty?
									overtime = overtime_table.overlaps(current_day, current_day).first
								else
									overtime = nil
								end
								unless overtime.nil?
		    					  result_alloc = result_alloc + ((overtime.overtime_hours.to_f * 100.0) / (overtime.overtime_days_count * actual_dailyhours))
		 						end

		 						#__result
		 						output += result_alloc
							
							else
								#other attribut :  logged_time: 3, check_ratio: 4 
								#their calculation it done directly on WlSeries.get_array_data()
								#so not call here
							end

							nb_increment = nb_increment+1
						end
					end

					current_day = current_day+1
				end #current_day = end_recc_date => end of the week
				case category_operation
				when 1 # average
					output = (output/nb_increment).round(2) unless nb_increment == 0
				else # when 0: sum
					#do nothing because output is already a sum of the allocs of the period
				end
				return output	
			end


			def convert_table_alloc_to_hours(table_data)
				table_result = []
				actual_wwhours = self.user.actual_weekly_working_hours
				table_result = table_data.map{|alloc| alloc*actual_wwhours/(5*100)}
				return table_result
			end

			def convert_table_alloc_to_fte(table_data)
				table_data.map{|datum| (datum/100.00).round(2)}
			end

			def convert_hours_to_fte(table_data)
				table_result = []
				actual_dwhours = self.user.actual_weekly_working_hours/5
				table_result = table_data.map{|datum| (datum/actual_dwhours).round(2)}
				return table_result
			end

			def convert_hours_to_percent(table_data)
				table_result = []
				actual_dwhours = self.user.actual_weekly_working_hours/5
				table_result = table_data.map{|datum| ((datum*100)/actual_dwhours).round(2)}
				return table_result
			end

			def gr_entry_data(start_period, end_period, category_hash, granularity, attribut_type, category_operation, unit_key)
				entry_data =[]
				case attribut_type
				when 3 # logged_time	
					category_hash.each do |gr_date|
						if self.user.get_logged_time(self.project, gr_date.last.first, gr_date.last.last).nil?
							entry_datum = 0
						else
							entry_datum = self.user.get_logged_time(self.project, gr_date.last.first, gr_date.last.last).values.sum 
						end
						case category_operation
						when 1 # average
							total_working_days = self.user.working_days_count(gr_date.last.first, gr_date.last.last)
							entry_datum = (entry_datum/total_working_days).round(2) unless total_working_days == 0
						else #when 0: sum
							# do nothing because it is already a sum of value for the period
						end
						entry_data << entry_datum
					end	
					#data conversion depending of the unit (fte, hours, %) - here, the raw_data is in hours
					case unit_key
					when 0 #fte
						entry_data = self.convert_hours_to_fte(entry_data)				
					when 1 #hours
						#dont need to do anything
					when 2 #%
						entry_data = self.convert_hours_to_percent(entry_data)
					else
					end
						
				when 4 # check_ratio
						
					category_hash.each do |gr_date|
						if self.get_check_ratio(gr_date.last.first, gr_date.last.last).nil?
							entry_data << 0
						else
							entry_data << self.get_check_ratio(gr_date.last.first, gr_date.last.last) 
						end
					end
				else # project_allocation: 0, total_allocation: 1, remaining_allocation: 2, real_allocation : 5
					entry_data = self.gr_calcul_alloc(start_period, end_period, granularity, attribut_type, category_operation)
					
					#data conversion depending of the unot (fte, hours, %) - here the raw_data is in %
					case unit_key
					when 0 #fte
						entry_data = self.convert_table_alloc_to_fte(entry_data)
					when 1 #hours
						entry_data = self.convert_table_alloc_to_hours(entry_data)
					when 2 #%
						#dont need to do anything 
					else
					end

				end
				return entry_data

			end	

		end
	end
end

unless Member.included_modules.include?(RedmineWorkloadCapacity::Patches::MemberPatch)
  Member.send(:include, RedmineWorkloadCapacity::Patches::MemberPatch)
end