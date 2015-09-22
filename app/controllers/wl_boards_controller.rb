class WlBoardsController < ApplicationController
  unloadable
  include WlCommon

  menu_item :workload

  before_action :find_project
  before_action :authenticate

  def index
  	

  	unless @project.wl_window?
  	 	flash[:error] = l(:error_project_windows_not_set)
  	 	redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
    
      return

    end
    
  	@wl_members ||= @project.wl_members

  end

  private

  def find_project
    @project ||= Project.find(params[:project_id])
  end

end