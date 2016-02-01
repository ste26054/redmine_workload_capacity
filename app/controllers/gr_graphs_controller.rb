class GrGraphsController < ApplicationController
  unloadable
  include WlCommon
  include WlSeries

  menu_item :workload
 
  helper :wl_boards

  before_action :set_project
  before_action :authenticate
  before_action :get_graph, only: [:set_params, :display_graph]

  def index
    @user = User.current
    @blocks = @user.pref[:gr_dashboard]
  end

  def personalise_index
    @user = User.current
    @blocks = @user.pref[:gr_dashboard]
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

  def display_graph  
  # render plain: "_____params[:gr_graph_id]: #{params[:gr_graph_id]}_______@gr_graph: #{@gr_graph}___________" 
  # return

      
   # render :js => "display_graph(#{@project.id},#{@gr_graph.id});"  
   #  return
    render :layout => false
  end

    # Add a block to user's page
  # The block is added on top of the page
  # params[:block] : id of the block to add
  def add_block
    block = params[:block].to_s.underscore
    if block.present?
      gr_graph_id = block[/\d+/].to_i
      graph_search = GrGraph.find(gr_graph_id)
      unless graph_search.nil?
        @user = User.current
        layout = @user.pref[:gr_dashboard] || {}
        # remove if already present in a group
        %w(top left right).each {|f| (layout[f] ||= []).delete block }
        # add it on top
        layout['top'].unshift block
        @user.pref[:gr_dashboard] = layout
        @user.pref.save
      end
    end
    redirect_to personalise_index_project_gr_graphs_path
  end

  # Remove a block to user's page
  # params[:block] : id of the block to remove
  def remove_block
    block = params[:block].to_s.underscore
    @user = User.current
    # remove block in all groups
    layout = @user.pref[:gr_dashboard] || {}
    %w(top left right).each {|f| (layout[f] ||= []).delete block }
    @user.pref[:gr_dashboard] = layout
    @user.pref.save
    redirect_to personalise_index_project_gr_graphs_path
  end

  # Change blocks order on user's page
  # params[:group] : group to order (top, left or right)
  # params[:list-(top|left|right)] : array of block ids of the group
  def order_blocks
    group = params[:group]
    @user = User.current
    if group.is_a?(String)
      group_items = (params["blocks"] || []).collect(&:underscore)
      group_items.each {|s| s.sub!(/^block_/, '')}
      if group_items and group_items.is_a? Array
        layout = @user.pref[:gr_dashboard] || {}
        # remove group blocks if they are presents in other groups
        %w(top left right).each {|f|
          layout[f] = (layout[f] || []) - group_items
        }
        layout[group] = group_items
        @user.pref[:gr_dashboard] = layout
        @user.pref.save
      end
    end
    render :nothing => true
  end

  private

  def get_graph
    @gr_graph = GrGraph.find(params[:gr_graph_id])
  end


end