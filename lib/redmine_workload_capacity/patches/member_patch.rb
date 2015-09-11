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
				table_allocs = self.wl_table_allocation
				table_periods = table_allocs

				table_periods.each_with_index do |t|
					return t[:percent_alloc] if (t[:start_date]..t[:end_date]).overlaps?(time_period) && from >= t[:start_date] && to <= t[:end_date]
				end
				return nil
			end

			# Returns the total cross project allocation table, bound to current project window
			def wl_global_table_allocation
				user_table_alloc = self.user.wl_table_allocation

				#wl_custom_project_windows = WlCustomProjectWindow.where(user_id: self.user.id, wl_project_window_id: self.project.wl_project_window)

				user_project_window = self.project.wl_project_window

				#if wl_custom_project_windows.empty?
					user_table_alloc.delete_if {|e| user_project_window.start_date > e[:end_date] || user_project_window.end_date < e[:start_date]}
				#else

				#end

				return user_table_alloc
			end

			# Returns the total remaining cross project allocation table, excluding current project allocations, bound to current project window
			def wl_remaining_table_allocation
				project_alloc = self.wl_table_allocation
				total_alloc = self.wl_global_table_allocation
				output = self.wl_global_table_allocation

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
		end
	end
end

unless Member.included_modules.include?(RedmineWorkloadCapacity::Patches::MemberPatch)
  Member.send(:include, RedmineWorkloadCapacity::Patches::MemberPatch)
end