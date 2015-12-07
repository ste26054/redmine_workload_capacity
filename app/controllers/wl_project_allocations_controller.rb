class WlProjectAllocationsController < ApplicationController
  unloadable
  include WlCommon

  before_action :set_project
  before_action :authenticate
  before_action :set_user, :set_member, :retrieve_project_alloc

  def new
    if @project_allocation
      redirect_to edit_project_user_wl_project_allocation_path
    else
      @project_allocation ||= WlProjectAllocation.new
    end
  end

  def create
    @project_allocation = WlProjectAllocation.new(wl_project_allocation_params)
    @project_allocation.user_id = @user.id
    @project_allocation.wl_project_window_id = @project.wl_project_window.id

    if @project_allocation.save
      flash[:notice] = l(:notice_project_allocation_set, :project => @project.name) 
       msg = ""
     msg << flash[:notice] unless flash[:notice].blank?
      #redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
      respond_to do |format|
        format.js { render :js => "refresh_member_contentline(#{@project.id},#{@member.id}, '#{msg}',true );" } #this is the second time format.js has been called in this controller! 
      end
    else
      flash[:error] = l(:error_set)
      render :new
    end
  end

  def edit
  end

  def update
    if @project_allocation.update(wl_project_allocation_params)
      flash[:notice] = l(:notice_project_allocation_set, :project => @project.name) 
      msg = ""
      msg << flash[:notice] unless flash[:notice].blank?
      #redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
      respond_to do |format|
        format.js { render :js => "refresh_member_contentline(#{@project.id},#{@member.id}, '#{msg}', true );" } #this is the second time format.js has been called in this controller! 
      end
    else
      flash[:error] = l(:error_set)
      render :edit
    end
  end

  private

  def set_user
  	@user ||= User.find(params[:user_id])
  end

  def set_project
  	@project ||= Project.find(params[:project_id])
  end

  def set_member
    @member ||= Member.find_by(user_id: @user.id, project_id: @project.id)
  end

  def wl_project_allocation_params
    params.require(:wl_project_allocation).permit(:percent_alloc)
  end

  def retrieve_project_alloc
    @project_allocation ||= WlProjectAllocation.find_by(user_id: @user.id, wl_project_window_id: @project.wl_project_window.id)
  end

end