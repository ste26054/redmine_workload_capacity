require 'redmine'
require 'redmine_workload_capacity'

Redmine::Plugin.register :redmine_workload_capacity do
	requires_redmine_plugin :redmine_leaves_holidays, :version_or_higher => '0.1'

  name 'Redmine Workload Capacity plugin'
  author 'Stephane Evrard'
  description 'A Redmine Plugin for managing work capacity across projects'
  version '0.0.1'

  menu :project_menu, :workload, { :controller => 'wl_boards', :action => 'index'},
                              :caption => :label_workload,
                              :after => :gantt,
                              :param => :project_id

  project_module :allocation_capacity do
  	permission :manage_project_allocation, {:wl_boards => [:index]}
  	permission :appear_in_project_allocation, {:wl_boards => [:index]}
  end
  
end