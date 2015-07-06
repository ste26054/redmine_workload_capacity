class WlUserOvertime < ActiveRecord::Base
  unloadable

  belongs_to :wl_project_window, :user

end