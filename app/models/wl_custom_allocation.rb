class WlCustomAllocation < ActiveRecord::Base
  unloadable
  include WlScopeExtension::Dates
  include WlScopeExtension::Users
  include WlCommonValidation

  belongs_to :wl_project_window
  belongs_to :user

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true
  validates :wl_project_window_id, presence: true
  validates :user_id, presence: true
  validates :percent_alloc, numericality: true, inclusion: { in: 0..100 }

  validate :end_date_not_before_start_date
  validate :dates_not_beyond_project_window
  validate :custom_alloc_per_user_uniq_within_period
  validate :dates_not_beyond_custom_project_window

  after_create :update_project_allocation

  attr_accessible :start_date, :end_date, :percent_alloc, :wl_project_window_id, :user_id

private

def update_project_allocation
  self.user.wl_project_allocations.find_by(wl_project_window_id: wl_project_window_id).touch()

end

end