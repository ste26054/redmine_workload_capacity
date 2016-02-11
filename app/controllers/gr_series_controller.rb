class GrSeriesController < ApplicationController
  unloadable
  include WlCommon
  include WlSeries

  menu_item :workload
 
  before_action :set_project
  before_action :authenticate

  before_action :get_graph

  def new
    @gr_series = GrSeries.new 
  end

  def create

    @properties = { color: params[:color_picker], attribut: params[:attribut], operation: params[:operation] }
    @gr_series = GrSeries.create(
      name: params[:name],
      chart_type: GrSeries.chart_types.select{|k,v| v == params[:chart_type].to_i}.keys.first, 
      properties: @properties,
      gr_graph_id: @gr_graph.id)

    if @gr_series.save
      @entries_id_list = params[:entry_id]
      @gr_entry = GrEntry.new
      @entries_id_list.each do |entry_id|
        @gr_entry = GrEntry.create(entry: params[:entry_type].to_s.constantize.find(entry_id), gr_series_id: @gr_series.id)
             unless @gr_entry.save
              flash[:error] = l(:error_grseries_create, :error_msg => @gr_entry.errors.full_messages)#"Create Series: Failed - #{@gr_entry.errors.full_messages}"
              @gr_series = GrSeries.destroy(@gr_series.id)
              render :new
              return
            end
      end 
 
      flash[:notice] = l(:notice_grseries_create)#"Create Series: Completed"
    else
      flash[:error] = l(:error_grseries_create, :error_msg => @gr_entry.errors.full_messages)#"Create Series: Failed - #{@gr_series.errors.full_messages}"
      render :new
      return
    end

    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :gr_graph_id => @gr_graph.id

  end

  def edit
    @gr_series = GrSeries.find(params[:id])
    @gr_entries_list = GrEntry.where(gr_series_id: params[:id])
  end

  def update 

    @gr_series = GrSeries.destroy(params[:id])
   
    @properties = { color: params[:color_picker], attribut: params[:attribut], operation: params[:operation] }
    @gr_series = GrSeries.create(
      name: params[:name],
      chart_type: GrSeries.chart_types.select{|k,v| v == params[:chart_type].to_i}.keys.first, 
      properties: @properties,
      gr_graph_id: @gr_graph.id)

    @entries_id_list = params[:entry_id]
    @entries_id_list.each do |entry_id|
      GrEntry.create(entry: params[:entry_type].to_s.constantize.find(entry_id), gr_series_id: @gr_series.id)
    end

    if @gr_series.save
      flash[:notice] = l(:notice_grseries_update)
    else
      flash[:error] = l(:error_grseries_update, :error_msg => @gr_entry.errors.full_messages)#"Update Series: Failed - #{@gr_series.errors.full_messages}"
      render :edit
      return
    end

    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :gr_graph_id => @gr_graph.id
  
  end

  def destroy
    @gr_series = GrSeries.destroy(params[:id])
    
    if @gr_series.save
      flash[:notice] = l(:notice_grseries_delete)
    else
      flash[:error] = l(:error_grseries_delete, :error_msg => @gr_entry.errors.full_messages)#"Delete Series: Failed - #{@gr_series.errors.full_messages}"
    end

    redirect_to :controller => 'gr_graphs', :action => 'set_params', :project_id => @project.id, :gr_graph_id => @gr_graph.id
  
  end

  private

  def get_graph
     @gr_graph = GrGraph.find(params[:gr_graph_id])
  end


end