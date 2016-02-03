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
				return self.memberships.to_a.delete_if {|m| !m.project_id.in?(wl_project_window_ids) || !m.project.module_enabled?(:allocation) || !WlUser.wl_member?(m) }
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

			def wl_view_global_right?(project)
				return WlUser.wl_view_global_right?(self, project)
			end

			def get_logged_time(project, from_date, to_date)
				User.current = self
				TimeEntryQuery.new(project: project).results_scope.where(user_id: self.id, :spent_on => from_date..to_date).group(:spent_on).sum(:hours)
		    end

		    def holiday_date_for_user(date)
		      region = self.leave_preferences.region.to_sym
		      date.holiday?(region, :observed)
		    end

		    def actual_weekly_working_hours
 				#TODO: needs to be removed after this identical function will be on production in the Leave management plugin
 				lp = self.leave_preferences
 				return (lp.weekly_working_hours * lp.overall_percent_alloc) / 100.0 
 			end

		end
	end
end

unless User.included_modules.include?(RedmineWorkloadCapacity::Patches::UserPatch)
  User.send(:include, RedmineWorkloadCapacity::Patches::UserPatch)
end