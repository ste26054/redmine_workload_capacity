class WlUserOvertimesController < ApplicationController
  unloadable
  include WlCommon

  before_action :set_project
  before_action :authenticate
  before_action :set_user
  before_action :retrieve_user_overtime, except: [:new, :create]
  before_action :retrieve_leave_list, except: [:destroy]

  def new
  	@user_overtime ||= WlUserOvertime.new
  end

  def create
  	@user_overtime = WlUserOvertime.new(wl_user_overtime_params)
    @user_overtime.user_id = @user.id
    @user_overtime.wl_project_window_id = @project.wl_project_window.id
  	if @user_overtime.save
      flash[:notice] = l(:notice_user_overtime_set, :user => @user.name)
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
    else
      flash[:error] = l(:error_set)
      render :new
    end
  end

  def edit
  end

  def update
  	if @user_overtime.update(wl_user_overtime_params)
      flash[:notice] = l(:notice_user_overtime_set, :user => @user.name)
      redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
    else
      flash[:error] = l(:error_set)
      render :edit
    end
  end

  def destroy
  	if @user_overtime.destroy
      flash[:notice] = l(:notice_user_overtime_deleted, :user => @user.name)
    else
      flash[:error] = l(:error_set)
    end
    redirect_to :controller => 'wl_boards', :action => 'index', :id => @project.id
  end

  private

  def wl_user_overtime_params
    params.require(:wl_user_overtime).permit(:start_date, :end_date, :overtime_hours, :include_sat, :include_sun, :include_bank_holidays)
  end

  def set_user
  	@user ||= User.find(params[:user_id])
  end

  def set_project
  	@project ||= Project.find(params[:project_id])
  end

  def retrieve_user_overtime
    @user_overtime ||= WlUserOvertime.find(params[:id])
  end

  def retrieve_leave_list
    @leave_list ||= WlUser.leave_request_list(@user, @project.wl_project_window)
  end

end