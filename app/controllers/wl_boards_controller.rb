class WlBoardsController < ApplicationController
  unloadable
  include WlUser

  menu_item :workload

  #before_filter :authorize

  def index
  	@project = Project.find(params[:project_id])

  	unless @project.wl_window?
  	 	flash[:error] = l(:error_project_windows_not_set)
  	 	redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
  	end
  	@wl_users = WlUser.wl_users_for_project(@project)

  end

end