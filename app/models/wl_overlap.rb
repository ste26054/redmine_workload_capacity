class WlOverlap < ActiveRecord::Base
  unloadable
  include WlScopeExtension::Dates
  include WlCommonValidation

  has_one :wl_project_overlap, dependent: :destroy

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true

  validate :end_date_not_before_start_date

  attr_accessible :start_date, :end_date
private
 
end