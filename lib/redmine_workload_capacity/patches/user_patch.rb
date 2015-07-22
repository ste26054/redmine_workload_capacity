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
			def wl_memberships
				return self.memberships.to_a.delete_if {|m| !self.allowed_to?(:appear_in_project_workload, m.project) || !m.project.wl_window?}
			end

			def wl_allocs
				hsh = []

				self.wl_memberships.each do |wl_member|
					alloc = wl_member.wl_allocation 
					hsh << alloc unless alloc.empty?
				end
				return hsh
			end

			def wl_table_allocation
				return WlLogic.generate_allocations_table_user(self)
			end
		end
	end
end

unless User.included_modules.include?(RedmineWorkloadCapacity::Patches::UserPatch)
  User.send(:include, RedmineWorkloadCapacity::Patches::UserPatch)
end