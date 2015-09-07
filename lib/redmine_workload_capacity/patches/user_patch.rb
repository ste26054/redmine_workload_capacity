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

			def wl_memberships
				wl_project_window_ids = WlProjectWindow.pluck(:project_id)
				return self.memberships.to_a.delete_if {|m| !m.project_id.in?(wl_project_window_ids) || !m.project.module_enabled?(:workload_capacity) || !WlUser.wl_member?(m) }
			end

			def wl_allocs
				hsh = []

				self.wl_memberships.each do |wl_member|
					alloc = WlLogic.wl_member_allocation(wl_member)
					hsh << alloc unless alloc.empty?
				end
				return hsh
			end

			# TO CACHE
			def wl_table_allocation
				wl_table_allocation =  WlLogic.generate_allocations_table_user(self)
			end

			def wl_manage_right?(project)
				return WlUser.wl_manage_right?(self, project)
			end
		end
	end
end

unless User.included_modules.include?(RedmineWorkloadCapacity::Patches::UserPatch)
  User.send(:include, RedmineWorkloadCapacity::Patches::UserPatch)
end