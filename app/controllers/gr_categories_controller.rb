class GrCategoriesController < ApplicationController
  unloadable
  include WlCommon

  menu_item :workload
 
  before_action :set_project
  before_action :authenticate

  def new
  	@gr_category = GrCategory.new
  end

  def create
  	@properties = {start_date: params[:start_date], end_date: params[:end_date], granularity: params[:granularity]}
  	
  	@gr_category_type =  GrCategory.gr_category_types.select{|k,v| v == params[:gr_category_type].to_i}.keys.first
  	
  	@gr_category = GrCategory.new(gr_category_type: @gr_category_type, properties: @properties, gr_graphs_id: 1)
  	
    # render plain: "****** gr_category_type= #{@gr_category_type} || @properties= #{@properties}******"
    # return

  	if @gr_category.save
      flash[:notice] = "YOUPI"
      # render :new
    else
      # .errors.full_messages
      flash[:error] = "Bouhou"
      # render :new
      render plain: "#{@gr_category.errors.full_messages} ***********"
      return
    end
    redirect_to :controller => 'gr_graphs', :action => 'new_graph', :id => @project.id, :tab => 'grgraph'

  end



  def destroy
    @gr_category = GrCategory.destroy(params[:id])

    # render plain: "*****params[:id]: #{params[:id]}******@gr_category: #{@gr_category}****"
    # return
    
    if @gr_category.save
      flash[:notice] = "DELETED"
       #render :new
    else
      # .errors.full_messages
      flash[:error] = "Bouhou - deleted"
      # render :new
      render plain: "#{@gr_category.errors.full_messages} ***********"
      return
    end

     redirect_to :controller => 'gr_graphs', :action => 'new_graph', :id => @project.id, :tab => 'grgraph'
  end

  private


end