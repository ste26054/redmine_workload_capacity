module RedmineWorkloadCapacity
	module Patches
		module  ProjectPatch
			def self.included(base) # :nodoc:
		        #base.extend(ClassMethods)

		        base.send(:include, ProjectInstanceMethods)

		        base.class_eval do
		          unloadable # Send unloadable so it will not be unloaded in development
		          has_one :wl_project_window
		        end
		    end
		end

		module ProjectInstanceMethods
			include WlUser
			def wl_users
				return WlUser.wl_users_for_project(self)
			end

			def wl_members
				return WlUser.wl_members_for_project(self)
			end

			def wl_window_defined?
				return WlProjectWindow.find_by(project_id: self.id) != nil
			end
		end
	end
end

unless Project.included_modules.include?(RedmineWorkloadCapacity::Patches::ProjectPatch)
  Project.send(:include, RedmineWorkloadCapacity::Patches::ProjectPatch)
end