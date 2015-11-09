require 'redmine'
require 'redmine_workload_capacity'

Redmine::Plugin.register :redmine_workload_capacity do
	requires_redmine_plugin :redmine_leaves_holidays, :version_or_higher => '0.1'
  requires_redmine_plugin :redmine_wktime, :version => '1.8.1'
	requires_redmine :version_or_higher => "3.0.0"

  name 'Redmine Allocation plugin'
  author 'Stephane Evrard'
  description 'A Redmine Plugin for managing work allocation across projects'
  version '0.1'

  menu :project_menu, :workload, { :controller => 'wl_boards', :action => 'index'},
                              :caption => :label_workload,
                              :after => :gantt,
                              :param => :project_id,
                              :if => Proc.new {|p| User.current.wl_manage_right?(p) || Member.find_by(user_id: User.current.id, project_id: p.id).wl_member?}

  project_module :allocation do
    permission :manage_project_allocation, {:wl_boards => [:index]}
    permission :view_allocation, {:wl_boards => [:index]}, :public => true
  end
  
end