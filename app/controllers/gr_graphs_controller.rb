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
    #only taking the title of the graph from textfield
    @gr_graph = GrGraph.new(plugin_reference: "allocation", name: params[:graph_name], user_id: User.current.id, project_id: @project.id )
    
    if @gr_graph.save 
      flash[:notice] = "Initiate Graph basis: Completed"
    else
      flash[:error] = "Initiate Graph basis: Failed"
      render :new
      return 
    end

    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :gr_graph_id => @gr_graph.id
  end

  def set_params

  end

  def draw    
  end

  def edit
    #only rename the graph
    @gr_graph = GrGraph.find(params[:id])
  end

  def update
    #only rename the graph
    @gr_graph = GrGraph.update(params[:id], name: params[:graph_name])

     if @gr_graph.save 
      flash[:notice] = "Update Graph title: Completed"
    else
      flash[:error] = "Update Graph title: Failed"
      render :edit
      return
    end

    render :index

  end

  def destroy
    @gr_graph = GrGraph.destroy(params[:id])

    if @gr_graph.save
      flash[:notice] = "Delete Graph: Completed"
    else
      flash[:error] = "Delete Graph: Failed - #{@gr_graph.errors.full_messages}"
    end
    #render :index
    redirect_to :controller => 'gr_graphs', :action => 'index', :project_id => @project.id
  end


  private

  def get_graph
    @gr_graph = GrGraph.find(params[:gr_graph_id])
  end


end