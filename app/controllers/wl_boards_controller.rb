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
    if !User.current.wl_manage_right?(@project) && !User.current.admin?
      if User.current.allowed_to?(:view_global_allocation_check, @project) || Member.find_by(user_id: User.current.id, project_id: @project.id).nil? ? false : Member.find_by(user_id: User.current.id, project_id: @project.id).wl_member?  
        redirect_to :controller => 'wl_check_loggedtime', :action => 'show', :id => @project.id, :tab => 'wlcheck'
        return
      end
    end

  	@wl_members ||= @project.wl_members

  end

  def update_wlconfigure_member_contentline
    
    @member ||= Member.find(params[:member_id])
    
    render :layout => false
  end

  private

  def find_project
    @project ||= Project.find(params[:project_id])
  end

end