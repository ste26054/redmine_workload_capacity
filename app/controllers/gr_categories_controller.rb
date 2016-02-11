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

  	@properties = {start_date: params[:start_date], end_date: params[:end_date], granularity: params[:granularity], operation: params[:operation]}
  	
  	@gr_category_type =  GrCategory.gr_category_types.select{|k,v| v == params[:gr_category_type].to_i}.keys.first
  	
  	@gr_category = GrCategory.new(gr_category_type: @gr_category_type, properties: @properties, gr_graph_id: @gr_graph.id)
 
  	if @gr_category.save
      flash[:notice] = l(:notice_grcategory_create)#"Create Category data: Completed" 
    else
      flash[:error] = l(:error_grcategory_create, :error_msg => @gr_category.errors.full_messages)#"Create Category data: Failed - #{@gr_category.errors.full_messages}"
      render :new
      return
    end
    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :gr_graph_id => @gr_graph.id
    
  end

  def edit
    @gr_category = GrCategory.find_by(gr_graph_id: @gr_graph.id)
  end

  def update

    @gr_category = GrCategory.find_by(gr_graph_id: @gr_graph.id)

    @properties = {start_date: params[:start_date], end_date: params[:end_date], granularity: params[:granularity], operation: params[:operation]}

    @gr_category = GrCategory.update(@gr_category.id, properties: @properties)

    if @gr_category.save
      flash[:notice] = l(:notice_grcategory_update)#"Update Category data: Completed"
    else
      flash[:error] = l(:error_grcategory_update, :error_msg => @gr_entry.errors.full_messages)#"Update Category data: Failed - #{@gr_category.errors.full_messages}"
      render :edit
      return
    end
    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :gr_graph_id => @gr_graph.id
  
  end


  def destroy
    @gr_category = GrCategory.find_by(gr_graph_id: @gr_graph.id).destroy
    
    if @gr_category.save
      flash[:notice] = l(:notice_grcategory_delete)#"Delete Category data: Completed"
    else
      flash[:error] = l(:error_grcategory_delete, :error_msg => @gr_entry.errors.full_messages)#"Delete Category data: Failed - #{@gr_category.errors.full_messages}"
    end
    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :id => @gr_graph.id, :tab => 'grgraph'
  
  end

  private

  def get_graph
     @gr_graph = GrGraph.find(params[:gr_graph_id])
  end

end