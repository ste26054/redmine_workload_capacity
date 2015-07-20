class WlProjectAllocationsController < ApplicationController
  unloadable

  before_action :set_project, :set_user, :retrieve_project_alloc

  def new
    if @project_allocation
      redirect_to edit_project_user_wl_project_allocation_path
    else
      @project_allocation = WlProjectAllocation.new
    end
  end

  def create
    @project_allocation = WlProjectAllocation.new(wl_project_allocation_params)
    @project_allocation.user_id = @user.id
    @project_allocation.wl_project_window_id = @project.wl_project_window.id

    if @project_allocation.save
      flash[:notice] = l(:notice_project_allocation_set, :project => @project.name)
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
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
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
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

  def wl_project_allocation_params
    params.require(:wl_project_allocation).permit(:percent_alloc, :wl_project_window_id, :user_id)
  end

  def retrieve_project_alloc
    @project_allocation ||= WlProjectAllocation.find_by(user_id: @user.id, wl_project_window_id: @project.wl_project_window.id)
  end

end