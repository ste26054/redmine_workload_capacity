module RedmineWorkloadCapacity
	module Patches
		module  UserPatch
			def self.included(base) # :nodoc:

				base.send(:include, UserInstanceMethods)

		        base.class_eval do
		          unloadable # Send unloadable so it will not be unloaded in development
		          has_many :wl_project_allocations
		        end
		    end
		end

		module UserInstanceMethods
			def wl_allocs
				# {projects: [
				# 	project_id: ...
				# 	default_alloc: ...
				# 	allocs: [{ 	alloc_id: ...
				# 				from: ...
				# 				to: ...	
				# 				percent_alloc: ...
				# 			}]
				# 		   ]
				# }
			end
		end
	end
end

unless User.included_modules.include?(RedmineWorkloadCapacity::Patches::UserPatch)
  User.send(:include, RedmineWorkloadCapacity::Patches::UserPatch)
end