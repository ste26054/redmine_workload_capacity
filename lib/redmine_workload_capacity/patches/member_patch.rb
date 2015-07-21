module RedmineWorkloadCapacity
	module Patches
		module  MemberPatch
			def self.included(base) # :nodoc:
		        #base.extend(ClassMethods)

		        base.send(:include, MemberInstanceMethods)

		        base.class_eval do
		          unloadable # Send unloadable so it will not be unloaded in development

		        end
		    end
		end

		module MemberInstanceMethods
			include WlLogic
			def wl_allocation
				return WlLogic.wl_member_allocation(self)
			end

			def wl_project_allocation
				return WlProjectAllocation.find_by(user_id: self.user_id, wl_project_window_id: self.project.wl_project_window.id)
			end

			def wl_project_allocation?
				return self.wl_project_allocation != nil
			end

			def wl_table_allocation
				return WlLogic.generate_allocations_table(self)
			end
		end
	end
end

unless Member.included_modules.include?(RedmineWorkloadCapacity::Patches::MemberPatch)
  Member.send(:include, RedmineWorkloadCapacity::Patches::MemberPatch)
end