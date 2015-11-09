class WlCheckLoggedtimeController < ApplicationController
  unloadable
  include WlCommon
 
  helper :wl_boards
  helper :wl_check_loggedtime
  
  before_action :set_user
  before_action :find_project
  before_action :authenticate


  def show

    h2 = {:project => @project}

    @timeline = RedmineWorkloadCapacity::Helpers::WlTimetable.new(params.merge(h2) )
    @timeline.project ||= @project
    if !User.current.wl_manage_right?(@project) && Member.find_by(user_id: User.current.id, project_id: @project.id).wl_member?
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