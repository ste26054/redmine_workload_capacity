class WlCustomAllocation < ActiveRecord::Base
  unloadable

  belongs_to :project, :user

end