module RedmineWorkloadCapacity
	module Patches
		module  ProjectPatch
			def self.included(base) # :nodoc:
		        #base.extend(ClassMethods)

		        base.send(:include, ProjectInstanceMethods)

		        base.class_eval do
		          unloadable # Send unloadable so it will not be unloaded in development
		          has_one :wl_project_window
		          after_save :wl_reload
		        end
		    end
		end

		module ProjectInstanceMethods
			include WlUser
			include WlLogic

			def wl_reload
				Rails.logger.info "WL_PROJECT_RELOADED"
				@wl_users = nil
				@wl_members = nil
				@has_wl_window = nil
				@wl_overlaps = nil
			end

			def wl_users
				@wl_users ||= WlUser.wl_users_for_project(self)
			end

			def wl_members
				@wl_members ||= WlUser.wl_members_for_project(self)
			end

			def wl_window?
				return WlProjectWindow.find_by(project_id: self.id) != nil
			end

			def wl_overlaps
				@wl_overlaps ||= WlLogic.wl_project_overlaps(self)
			end
		end
	end
end

unless Project.included_modules.include?(RedmineWorkloadCapacity::Patches::ProjectPatch)
  Project.send(:include, RedmineWorkloadCapacity::Patches::ProjectPatch)
end