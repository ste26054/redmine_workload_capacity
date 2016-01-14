class GrGraphsController < ApplicationController
  unloadable
  include WlCommon
  include WlSeries

  menu_item :workload
 
  helper :wl_boards

  before_action :set_project
  before_action :authenticate
  before_action :get_graph, only: [:set_params]

  def index
  end

  def new
    @gr_graph = GrGraph.new
  end

  def create
    @gr_graph = GrGraph.new(plugin_reference: "allocation", name: params[:graph_name], user_id: User.current.id, project_id: @project.id )
    
    if @gr_graph.save 
      flash[:notice] = "YOUPI - your graph has been created"
    else
      flash[:error] = "BOUHOU - graph creation failed"
      render plain: "#{@gr_graph.errors.full_messaged} **************"
      return
    end

    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :gr_graph_id => @gr_graph.id
  end

  def set_params

  end

  def draw    
  end

  def edit
    @gr_graph = GrGraph.find(params[:id])
    #only rename the graph
  end

  def update
    #only rename the graph
    @gr_graph = GrGraph.update(params[:id], name: params[:graph_name])

     if @gr_graph.save 
      flash[:notice] = "YOUPI - your graph has been renamed"
    else
      flash[:error] = "BOUHOU"
      render plain: "#{@gr_graph.errors.full_messaged} **************"
      return
    end

    render :index

  end

  def destroy
    @gr_graph = GrGraph.destroy(params[:id])

    if @gr_graph.save
      flash[:notice] = "YOUPI - graph deleted"
    else
      flash[:error] = "Bouhou - graph not deleted"
      render plain: "#{@gr_graph.errors.full_messages} ************"
      return
    end
    render :index

  end


  private

  def get_graph
    @gr_graph = GrGraph.find(params[:gr_graph_id])
  end


end