class WlProjectWindowsController < ApplicationController
  unloadable

  before_action :set_project, :retrieve_project_window

  def new
  	@project_window = WlProjectWindow.new
  end

  def create
  	@project_window = WlProjectWindow.new(wl_project_window_params)
  	@project_window.project_id = @project.id
  	if @project_window.save
  		flash[:notice] = "The project window was correctly set"
  		render new_project_wl_project_windows_path
  	else
  		flash[:error] = "An error occured. Please check that your parameters are correct"
  		render new_project_wl_project_windows_path
  	end
  end

  def edit
  end

  def update

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