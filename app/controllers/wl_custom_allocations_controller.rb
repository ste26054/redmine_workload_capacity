class WlCustomAllocationsController < ApplicationController
  unloadable

  before_action :set_project, :set_user
  before_action :retrieve_custom_alloc, except: [:new, :create]

  def new
  	@custom_allocation = WlCustomAllocation.new
  end

  def create
  	@custom_allocation = WlCustomAllocation.new(wl_custom_allocation_params)
    @custom_allocation.user_id = @user.id
    @custom_allocation.wl_project_window_id = @project.wl_project_window.id
  	if @custom_allocation.save
      flash[:notice] = l(:notice_custom_allocation_set, :user => @user.name)
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
    else
      flash[:error] = l(:error_set)
      render :new
    end
  end

  def edit
  end

  def update
  	if @custom_allocation.update(wl_custom_allocation_params)
      flash[:notice] = l(:notice_custom_allocation_set, :user => @user.name)
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
    else
      flash[:error] = l(:error_set)
      render :edit
    end
  end

  def destroy
  	@custom_allocation.destroy
    redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
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

  def retrieve_custom_alloc
    @custom_allocation ||= WlCustomAllocation.find(params[:id])
  end

end