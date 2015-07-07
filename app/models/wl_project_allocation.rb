class WlProjectAllocation < ActiveRecord::Base
  unloadable

  belongs_to :wl_project_window
  belongs_to :user

end