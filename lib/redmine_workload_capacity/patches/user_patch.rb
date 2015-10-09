module RedmineWorkloadCapacity
	module Patches
		module  UserPatch
			def self.included(base) # :nodoc:

				base.send(:include, UserInstanceMethods)

		        base.class_eval do
		          unloadable # Send unloadable so it will not be unloaded in development
		          has_many :wl_project_allocations
		          has_many :wl_custom_allocations
		        end
		    end
		end

		module UserInstanceMethods
			include WlUser

			# Returns memberships of the user with a project window defined, where the allocation module is activated, where the user has sufficient permissions
			def wl_memberships
				wl_project_window_ids = WlProjectWindow.pluck(:project_id)
				return self.memberships.to_a.delete_if {|m| !m.project_id.in?(wl_project_window_ids) || !m.project.module_enabled?(:allocation_capacity) || !WlUser.wl_member?(m) }
			end

			# Generates a table of the various allocations of the user (project, custom) for all of his wl_projects
			# Gets default project allocation + all custom allocations set
			def wl_user_allocations_extract
				hsh = []

				self.wl_memberships.each do |wl_member|
					alloc = wl_member.wl_member_allocations_extract
					hsh << alloc unless alloc.empty?
				end
				return hsh
			end

			# Gives the allocation table for a user, for all his projects bound to sufficient permissions, at project window defined, the project module is activated
			def wl_table_allocation
				wl_table_allocation =  WlLogic.generate_allocations_table_user(self)
			end

			def wl_manage_right?(project)
				return WlUser.wl_manage_right?(self, project)
			end

			def working_days_count(from_date, to_date, include_sat = false, include_sun = false, include_bank_holidays = false)
				user_region = LeavesHolidaysLogic.user_params(self, :region)
				dates_interval = (from_date..to_date).to_a
				
				return dates_interval.count if include_sat && include_sun && include_bank_holidays

    			dates_interval.delete_if {|i| i.wday == 6 && !include_sat || #delete date from array if day of week is a saturday (6)
                			              i.wday == 0 && !include_sun || #delete date from array if day of week is a sunday (0)
                            		      !include_bank_holidays && i.holiday?(user_region.to_sym, :observed)
    									 }

    			return dates_interval.count

			end

		end
	end
end

unless User.included_modules.include?(RedmineWorkloadCapacity::Patches::UserPatch)
  User.send(:include, RedmineWorkloadCapacity::Patches::UserPatch)
end