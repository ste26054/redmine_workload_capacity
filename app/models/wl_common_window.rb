class WlCommonWindow < ActiveRecord::Base
  unloadable

  belongs_to :wl_overlap
  belongs_to :wl_project_window

end