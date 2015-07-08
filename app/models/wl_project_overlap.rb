class WlProjectOverlap < ActiveRecord::Base
  unloadable

	belongs_to :wl_overlap
	belongs_to :wl_project_window

	validates :wl_project_window_id, presence: true
  	validates :wl_overlap_id, presence: true

	attr_accessible :wl_overlap_id, :wl_project_window_id
end