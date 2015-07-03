class WlUserOvertime < ActiveRecord::Base
  unloadable

  belongs_to :project, :user

end