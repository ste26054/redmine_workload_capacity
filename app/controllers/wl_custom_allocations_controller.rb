class WlCustomAllocationsController < ApplicationController
  unloadable

  def new
  	@custom_allocation = WlCustomAllocation.new
  end

  def create
  	
  end

  def edit
  	
  end

  def update
  	
  end

  def destroy
  	
  end

  private

  def wl_custom_allocation_params
    params.require(:wl_custom_allocation).permit(:start_date, :end_date, :percent_alloc, :wl_project_window_id, :user_id)
  end

end