class WlProjectWindow < ActiveRecord::Base
  unloadable

  belongs_to :project
  #has_many :wl_project_allocation, :wl_custom_allocation, :wl_user_overtime

end