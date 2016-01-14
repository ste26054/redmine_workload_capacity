class GrCategoriesController < ApplicationController
  unloadable
  include WlCommon

  menu_item :workload
 
  before_action :set_project
  before_action :authenticate

  before_action :get_graph

  def new
  	@gr_category = GrCategory.new
  end

  def create
  	@properties = {start_date: params[:start_date], end_date: params[:end_date], granularity: params[:granularity]}
  	
  	@gr_category_type =  GrCategory.gr_category_types.select{|k,v| v == params[:gr_category_type].to_i}.keys.first
  	
  	@gr_category = GrCategory.new(gr_category_type: @gr_category_type, properties: @properties, gr_graph_id: @gr_graph.id)
  	
    # render plain: "****** gr_category_type= #{@gr_category_type} || @properties= #{@properties}******"
    # return

  	if @gr_category.save
      flash[:notice] = "YOUPI"
    else
      flash[:error] = "Bouhou"

      render plain: "#{@gr_category.errors.full_messages} ***********"
      return
    end
    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :gr_graph_id => @gr_graph.id

  end

  def edit
    @gr_category = GrCategory.find_by(gr_graph_id: @gr_graph.id)

  end

  def update
    @gr_category = GrCategory.find_by(gr_graph_id: @gr_graph.id)

    @properties = {start_date: params[:start_date], end_date: params[:end_date], granularity: params[:granularity]}

    @gr_category = GrCategory.update(@gr_category.id, properties: @properties)

    if @gr_category.save
      flash[:notice] = "YOUPI"
    else
      flash[:error] = "Bouhou"

      render plain: "#{@gr_category.errors.full_messages} ***********"
      return
    end

    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :gr_graph_id => @gr_graph.id
  end


  def destroy
    @gr_category = GrCategory.find_by(gr_graph_id: @gr_graph.id).destroy
    
    if @gr_category.save
      flash[:notice] = "DELETED"
    else
      flash[:error] = "Bouhou - not deleted"
 
      render plain: "#{@gr_category.errors.full_messages} ***********"
      return
    end
    
    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :id => @gr_graph.id, :tab => 'grgraph'
  
  end

  private

  def get_graph
     @gr_graph = GrGraph.find(params[:gr_graph_id])
  end


end