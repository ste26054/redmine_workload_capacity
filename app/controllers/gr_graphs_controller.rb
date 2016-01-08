class GrGraphsController < ApplicationController
  unloadable
  include WlCommon
  include WlSeries

  menu_item :workload
 
  helper :wl_boards

  before_action :set_project
  before_action :authenticate

  def index

  end

  def new_graph
      @gr_category = GrCategory.new
      @series = GrSeries.new

  end

  def new_series

  end

  def new_category

  end

  private

end