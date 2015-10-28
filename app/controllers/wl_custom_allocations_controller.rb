class WlCustomAllocationsController < ApplicationController
  unloadable
  include WlCommon

  before_action :set_project
  before_action :set_user
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
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
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
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
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
    redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id, :tab => "wlconfigure"
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

  def retrieve_custom_project_window_list
    @custom_project_window_list ||= WlCustomProjectWindow.where(user_id: @user.id, wl_project_window_id: @project.wl_project_window.id).order(:start_date).to_a
  end

end