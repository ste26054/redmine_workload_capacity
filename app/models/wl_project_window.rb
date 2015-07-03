class WlProjectWindow < ActiveRecord::Base
  unloadable

  belongs_to :project

end