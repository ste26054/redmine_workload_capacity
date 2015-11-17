class WlCheckLoggedtimeController < ApplicationController
  unloadable
  include WlCommon
 
  helper :wl_boards
  helper :wl_check_loggedtime
  
  before_action :set_user
  before_action :find_project
  before_action :authenticate


  def show

   
    wl_pw = @project.wl_project_window
    acceptable_limit_low = (1 - (wl_pw.acceptable_check_limit.to_f/100)).round(2) 
    acceptable_limit_high = (1 + (wl_pw.acceptable_check_limit.to_f/100)).round(2) 
    danger_limit_low = (1 - (wl_pw.danger_check_limit.to_f/100)).round(2)    
    danger_limit_high = (1 + (wl_pw.danger_check_limit.to_f/100)).round(2) 
    @ratio_limits = [acceptable_limit_low, acceptable_limit_high, danger_limit_low, danger_limit_high]
    h2 = {:project => @project, :ratio_limits => @ratio_limits}

    @timeline = RedmineWorkloadCapacity::Helpers::WlTimetable.new(params.merge(h2) )
    @timeline.project ||= @project
    if !User.current.wl_manage_right?(@project) && !User.current.allowed_to?(:view_global_allocation_check, @project) && Member.find_by(user_id: User.current.id, project_id: @project.id).wl_member?
      @timeline.wl_users ||= [User.current]
    else
      @timeline.wl_users ||= @project.wl_users
    end
   
  end

  private
  

  def set_user
    @user ||= User.current
  end

  def find_project
    @project ||= Project.find(params[:project_id])
  end

 



end