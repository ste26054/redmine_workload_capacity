class GrEntry < ActiveRecord::Base
  unloadable

  belongs_to :entry, polymorphic: true # can be a Role or a User
  belongs_to :gr_series

  validates :entry, presence: true
  validates :gr_series_id, presence: true 

  scope :entry_role, lambda { where(entry: "Role")}
  scope :entry_user, lambda { where(entry: "Principal")}

  attr_accessible :entry, :gr_series_id

private

end