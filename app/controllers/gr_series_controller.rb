class GrSeriesController < ApplicationController
  unloadable
  include WlCommon
  include WlSeries

  menu_item :workload
 
  before_action :set_project
  before_action :authenticate

  def new
    @series = GrSeries.new 
  end

  def create

    @properties = { color: params[:color_picker], attribut: params[:attribut] }
    @series = GrSeries.create(
      name: params[:name],
      chart_type: GrSeries.chart_types.select{|k,v| v == params[:chart_type].to_i}.keys.first, 
      properties: @properties,
      gr_graphs_id: "1")

    @entries_id_list = params[:entry_id]
    @entries_id_list.each do |entry_id|
      GrEntry.create(entry: params[:entry_type].to_s.constantize.find(entry_id), gr_series_id: @series.id)
    end

    # render plain: "******* id : #{@series.id} *****"
    # return

    if @series.save
      flash[:notice] = "YOUPI"
      #render :new
    else
      flash[:error] = "Bouhou"

      render plain: "#{@series.errors.full_messages} ***********"
      return
    end

     redirect_to :controller => 'gr_graphs', :action => 'new_graph', :id => @project.id, :tab => 'grgraph'

  end

  def destroy
     @gr_series = GrSeries.destroy(params[:id])

    # render plain: "*****params[:id]: #{params[:id]}******@gr_category: #{@gr_category}****"
    # return
    
    if @gr_series.save
      flash[:notice] = "DELETED"
      # render :new
    else
      # .errors.full_messages
      flash[:error] = "Bouhou - deleted"
      # render :new
      render plain: "#{@gr_series.errors.full_messages} ***********"
      return
    end

     redirect_to :controller => 'gr_graphs', :action => 'new_graph', :id => @project.id, :tab => 'grgraph'
  end

  private


end