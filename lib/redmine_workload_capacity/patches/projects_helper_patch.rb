module RedmineWorkloadCapacity
	module Patches
		module  ProjectsHelperPatch
			def self.included(base)
				base.send(:include, InstanceMethods)

		        base.class_eval do
		          unloadable

		          alias_method_chain :project_settings_tabs, :workload
		        end
			end

			module InstanceMethods
		        def project_settings_tabs_with_workload
		          tabs = project_settings_tabs_without_workload

		          tabs.push({ :name => 'workload',
		                      :action => :view_workload,
		                      :partial => 'projects/workload_settings',
		                      :label => :label_workload}) if @project.module_enabled?(:workload_capacity)

		          tabs
		        end
		    end
		end
	end
end

unless ProjectsHelper.included_modules.include?(RedmineWorkloadCapacity::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineWorkloadCapacity::Patches::ProjectsHelperPatch)
end