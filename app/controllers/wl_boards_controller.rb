class WlBoardsController < ApplicationController
  unloadable
  include WlUser

  menu_item :workload

  #before_filter :authorize

  def index
  	@project = Project.find(params[:project_id])
  	# @project_window = WlProjectWindow.find_by(project_id: @project.id)

  	# if @project_window == nil
  	# 	flash[:error] = l(:error_project_windows_not_set)
  	# 	redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
  	# end
  	@wl_users = WlUser.wl_users_for_project(@project)

  end

end