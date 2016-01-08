class WlCustomProjectWindowsController < ApplicationController
	unloadable
	include WlCommon

	before_action :set_project
	before_action :set_user
	before_action :authenticate
	before_action :set_wl_project_window, :set_member
	before_action :retrieve_custom_project_window, except: [:new, :create]

	def new
		@custom_project_window = WlCustomProjectWindow.new
	end

	def create
		@custom_project_window = WlCustomProjectWindow.new(wl_custom_project_window_params)
		@custom_project_window.user_id = @user.id
		@custom_project_window.wl_project_window_id = @wl_project_window.id
		if @custom_project_window.save
			flash[:notice] = l(:notice_custom_project_windows_set, :project => @project.name, :user => @user.name) 
			#redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
			 msg = ""
    		 msg << flash[:notice] unless flash[:notice].blank?
			 respond_to do |format|
		        format.js { render :js => "refresh_member_contentline(#{@project.id},#{@member.id}, '#{msg}', true );" } #this is the second time format.js has been called in this controller! 
		      end
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
			#redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
			 msg = ""
     msg << flash[:notice] unless flash[:notice].blank?
     
			 respond_to do |format|
		        format.js { render :js => "refresh_member_contentline(#{@project.id},#{@member.id}, '#{msg}', true );" } #this is the second time format.js has been called in this controller! 
		      end
		else
			flash[:error] = l(:error_set)
			render :new
		end
	end

	def destroy
		if @custom_project_window.destroy
			#
			flash[:notice] = l(:notice_custom_allocation_deleted, :user => @user.name) 
 		else
 			flash[:error] = l(:error_delete_cpw) 
 	   end
 	    msg = ""
	    type_notice = true
	    unless flash[:notice].blank?
	     msg = ""
	     msg << flash[:notice] 
	     type_notice = true
	    end 
	   
	    unless flash[:error].blank?
	     msg = ""
	     msg << flash[:error]
	     type_notice = false
	    end
		#redirect_to :controller => 'wl_boards', :action => 'index', :tab => "wlconfigure"
		respond_to do |format|
       	 	format.js { render :js => "refresh_member_contentline(#{@project.id},#{@member.id}, '#{msg}', #{type_notice} );" } #this is the second time format.js has been called in this controller! 

      	end

	end


private

	def wl_custom_project_window_params
		params.require(:wl_custom_project_window).permit(:start_date, :end_date)
	end

	def set_user
		@user ||= User.find(params[:user_id])
	end

	def set_member
    	@member ||= Member.find_by(user_id: @user.id, project_id: @project.id)
  	end

	def set_wl_project_window
		@wl_project_window ||= WlProjectWindow.find_by(project_id: @project.id)
	end

	def retrieve_custom_project_window
		@custom_project_window ||= WlCustomProjectWindow.find_by(wl_project_window_id: @wl_project_window.id, user_id: @user.id, id: params[:id])
	end

end