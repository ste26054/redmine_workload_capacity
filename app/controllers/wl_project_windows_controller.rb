class WlProjectWindowsController < ApplicationController
  unloadable
  include WlCommon

  before_action :set_project
  before_action :authenticate
  before_action :retrieve_project_window
  before_action :retrieve_available_project_roles, only: [:new, :edit, :create]

  def new
  	if @project_window
  		redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
  	else
  		@project_window ||= WlProjectWindow.new
  	end
  end

  def create
  	@project_window = WlProjectWindow.new(wl_project_window_params)
  	@project_window.project_id = @project.id
    if @project_window.save
  		flash[:notice] = l(:notice_project_windows_set, :project => @project.name)
  		#redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
  	else
  		flash[:error] = l(:error_set)
  		render :new
  	end
  end

  def edit
  end

  def update
  	if @project_window.update(wl_project_window_params)
  		flash[:notice] = l(:notice_project_windows_set, :project => @project.name)
  		#redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
  	else
  		flash[:error] = l(:error_set)
  		render :edit
  	end
  	
  end

  def destroy
  	@project_window.destroy
  	redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
  end

private

  def wl_project_window_params
	  params.require(:wl_project_window).permit(:start_date, :end_date, :acceptable_check_limit, :danger_check_limit, :tooltip_role_ids => [], :display_role_ids => [])
  end

  def set_project
  	@project ||= Project.find(params[:project_id])
  end

  def retrieve_project_window
  	@project_window ||= WlProjectWindow.find_by(project_id: @project.id)
  end

  def retrieve_available_project_roles
    @available_project_roles ||= @project.members.to_a.map{ |member| member.roles.to_a.map{ |role| [role.name, role.id] }}.flatten(1).uniq.sort
  end

 

end