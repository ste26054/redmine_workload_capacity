class WlCheckLoggedtimeController < ApplicationController
  unloadable
  include WlCommon
 
  helper :wl_boards
  helper :wl_check_loggedtime
  
  before_action :set_user
  before_action :find_project
  before_action :authenticate


  def show
   
  # render plain: @project.wl_project_window.start_date
  #   return
  h2 = {:project => @project}
    
    @timeline = RedmineWorkloadCapacity::Helpers::WlTimetable.new(params.merge(h2) )
      @timeline.wl_users ||= @project.wl_users
       @timeline.project ||= @project
   
    #@wl_users ||= @project.wl_users
  end

  private
  

  def set_user
    @user ||= User.current
  end

  def find_project
    @project ||= Project.find(params[:project_id])
  end

 



end