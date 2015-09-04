class WlCustomProjectWindowsController < ApplicationController
	unloadable
	include WlCommon

	before_action :set_project
	before_action :set_user
	before_action :authenticate
	before_action :set_wl_project_window
	before_action :retrieve_custom_project_window

	def new
		if @custom_project_window
			redirect_to edit_project_user_wl_custom_project_window_path(@project, @user)
		else
			@custom_project_window ||= WlCustomProjectWindow.new
		end
	end

	def create
		@custom_project_window = WlCustomProjectWindow.new(wl_custom_project_window_params)
		@custom_project_window.user_id = @user.id
		@custom_project_window.wl_project_windows_id = @wl_project_window.id
		if @custom_project_window.save
			flash[:notice] = l(:notice_custom_project_windows_set, :project => @project.name, :user => @user.name)
			redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
		else
			flash[:error] = l(:error_set)
			render :new
		end
	end

	def edit
	end

	def update
		if @custom_project_window.update(wl_custom_project_window_params)
			flash[:notice] = l(:notice_custom_project_windows_set, :project => @project.name, :user => @user.name)
			redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
		else
			flash[:error] = l(:error_set)
			render :new
		end
	end

	def destroy
		@custom_project_window.destroy
		redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
	end

private

	def wl_custom_project_window_params
		params.require(:wl_custom_project_window).permit(:start_date, :end_date)
	end

	def set_user
		@user ||= User.find(params[:user_id])
	end

	def set_project
		@project ||= Project.find(params[:project_id])
	end

	def set_wl_project_window
		@wl_project_window ||= WlProjectWindow.find_by(project_id: @project.id)
	end

	def retrieve_custom_project_window
		@custom_project_window ||= WlCustomProjectWindow.find_by(wl_project_windows_id: @wl_project_window.id, user_id: @user.id)
	end

end