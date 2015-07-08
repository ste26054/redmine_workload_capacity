class WlProjectWindow < ActiveRecord::Base
  unloadable
  include WlScopeExtension::Dates
  include WlCommonValidation
  

  belongs_to :project
  attr_accessible :project_id, :start_date, :end_date

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true
  validates :project_id, presence: true

  validate :end_date_not_before_start_date

  attr_accessible :start_date, :end_date, :project_id
private

end