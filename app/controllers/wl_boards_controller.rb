class WlBoardsController < ApplicationController
  unloadable
  include WlUser

  menu_item :workload

  before_action :find_project

  def index
  	

  	unless @project.wl_window?
  	 	flash[:error] = l(:error_project_windows_not_set)
  	 	redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
  	end
    
  	@wl_members ||= @project.wl_members

  end

  private

  def find_project
    @project ||= Project.find(params[:project_id])
  end

end