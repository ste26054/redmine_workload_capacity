class WlBoardsController < ApplicationController
  unloadable

  menu_item :workload

  def index
  	@project = Project.find(params[:project_id])
  	@project_window = WlProjectWindow.find_by(project_id: @project.id)

  	render_404 if @project_window == nil
  end

end