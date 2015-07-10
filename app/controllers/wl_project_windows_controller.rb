class WlProjectWindowsController < ApplicationController
  unloadable

  before_action :set_project, :retrieve_project_window

  def new
  	if @project_window
  		redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
  	else
  		@project_window = WlProjectWindow.new
  	end
  end

  def create
  	@project_window = WlProjectWindow.new(wl_project_window_params)
  	@project_window.project_id = @project.id
  	if @project_window.save
  		flash[:notice] = l(:notice_project_windows_set)
  		redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
  	else
  		flash[:error] = l(:error_project_windows_set)
  		render :new
  	end
  end

  def edit
  end

  def update
  	if @project_window.update(wl_project_window_params)
  		flash[:notice] = l(:notice_project_windows_set)
  		redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
  	else
  		flash[:error] = l(:error_project_windows_set)
  		render :edit
  	end
  	
  end

  def destroy
  	@project_window.destroy
  	redirect_to :controller => 'projects', :action => 'settings', :id => @project.id, :tab => 'workload'
  end

private

  def wl_project_window_params
	params.require(:wl_project_window).permit(:project_id, :start_date, :end_date)
  end

  def set_project
  	@project ||= Project.find(params[:project_id])
  end

  def retrieve_project_window
  	@project_window ||= WlProjectWindow.find_by(project_id: @project.id)
  end

end