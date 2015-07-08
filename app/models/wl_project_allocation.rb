class WlProjectAllocation < ActiveRecord::Base
  unloadable

  belongs_to :wl_project_window
  belongs_to :user

  validates :wl_project_window_id, presence: true
  validates :user_id, presence: true

  attr_accessible :percent_alloc, :wl_project_window_id, :user_id

end