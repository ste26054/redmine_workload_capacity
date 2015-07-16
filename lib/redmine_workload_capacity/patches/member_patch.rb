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
		end
	end
end

unless Member.included_modules.include?(RedmineWorkloadCapacity::Patches::MemberPatch)
  Member.send(:include, RedmineWorkloadCapacity::Patches::MemberPatch)
end