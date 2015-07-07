module RedmineWorkloadCapacity
	module Patches
		module  UserPatch
			def self.included(base) # :nodoc:
		        base.class_eval do
		          unloadable # Send unloadable so it will not be unloaded in development
		          has_many :wl_project_allocations
		        end
		    end
		end
	end
end

unless User.included_modules.include?(RedmineWorkloadCapacity::Patches::UserPatch)
  User.send(:include, RedmineWorkloadCapacity::Patches::UserPatch)
end