class WlUserOvertime < ActiveRecord::Base
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
  validates :overtime_hours, presence: true, numericality: { :greater_than => 0 }

  validates :include_sat, inclusion: [true, false]
  validates :include_sun, inclusion: [true, false]
  validates :include_bank_holidays, inclusion: [true, false]

  validates :overtime_days_count, numericality: { :greater_than => 0, message: "must be > 0. Consider including Saturdays, Sundays and/or Bank Holidays" }

  validate :end_date_not_before_start_date
  validate :dates_not_beyond_project_window
  validate :custom_alloc_per_user_uniq_within_period
  validate :dates_not_beyond_custom_project_window

  attr_accessible :start_date, :end_date, :overtime_hours, :wl_project_window_id, :user_id, :include_sat, :include_sun, :include_bank_holidays


  def overtime_days_count
    user.working_days_count(start_date, end_date, include_sat, include_sun, include_bank_holidays)
  end

  def css_classes(from = nil, to = nil)
    leave_list = WlUser.leave_request_list(user, wl_project_window).overlaps(start_date, end_date)
    leave_list = leave_list.overlaps(from, to) if from != nil && to != nil
    s = 'wl-overtime'
    s << ' needs-attention' unless leave_list.empty?
    return s
  end

private
  
end