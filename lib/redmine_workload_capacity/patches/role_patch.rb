module RedmineWorkloadCapacity
  module Patches
    module  RolePatch
      def self.included(base) # :nodoc:

        base.send(:include, RoleInstanceMethods)

            base.class_eval do
              unloadable # Send unloadable so it will not be unloaded in development
              has_many :gr_entries, as: :entry
          

            end
        end
    end

    
  end
end

unless Role.included_modules.include?(RedmineWorkloadCapacity::Patches::RolePatch)
  Role.send(:include, RedmineWorkloadCapacity::Patches::RolePatch)
end