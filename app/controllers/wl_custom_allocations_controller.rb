class WlCustomAllocationsController < ApplicationController
  unloadable
  include WlCommon

  before_action :set_project
  before_action :set_user
  before_action :set_member
  before_action :authenticate
  before_action :retrieve_custom_alloc, except: [:new, :create]
  before_action :retrieve_custom_project_window_list

  def new
  	@custom_allocation ||= WlCustomAllocation.new
  end

  def create
  	@custom_allocation = WlCustomAllocation.new(wl_custom_allocation_params)
    @custom_allocation.user_id = @user.id
    @custom_allocation.wl_project_window_id = @project.wl_project_window.id
  	if @custom_allocation.save
      flash[:notice] = l(:notice_custom_allocation_set, :user => @user.name) 
      #redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
      #render :layout => false
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

  def update
  	if @custom_allocation.update(wl_custom_allocation_params)
      flash[:notice] = l(:notice_custom_allocation_set, :user => @user.name) 
     # redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
      msg = ""
      msg << flash[:notice] unless flash[:notice].blank?
      respond_to do |format|
        format.js { render :js => "refresh_member_contentline(#{@project.id},#{@member.id}, '#{msg}', true );" } #this is the second time format.js has been called in this controller! 
      end
    else
      flash[:error] = l(:error_set)
      render :edit
    end
  end

  def destroy
  	if @custom_allocation.destroy
      flash[:notice] = l(:notice_custom_allocation_deleted, :user => @user.name) 
    else
      flash[:error] = l(:error_set) 
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
    #render :layout => false
      respond_to do |format|
        format.js { render :js => "refresh_member_contentline(#{@project.id},#{@member.id}, '#{msg}', #{type_notice});" } #this is the second time format.js has been called in this controller! 
      end
    #render :nothing => true
   # redirect_to :nothing => true :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
  end

  private

  def wl_custom_allocation_params
    params.require(:wl_custom_allocation).permit(:start_date, :end_date, :percent_alloc)
  end

  def set_user
  	@user ||= User.find(params[:user_id])
  end

  def set_project
  	@project ||= Project.find(params[:project_id])
  end

  def set_member
    @member ||= Member.find_by(user_id: @user.id, project_id: @project.id)
  end

  def retrieve_custom_alloc
    @custom_allocation ||= WlCustomAllocation.find(params[:id])
  end

  def retrieve_custom_project_window_list
    @custom_project_window_list ||= WlCustomProjectWindow.where(user_id: @user.id, wl_project_window_id: @project.wl_project_window.id).order(:start_date).to_a
  end

end