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

  attr_accessible :start_date, :end_date, :overtime_hours, :wl_project_window_id, :user_id, :include_sat, :include_sun, :include_bank_holidays


  def overtime_days_count
    user_region = LeavesHolidaysLogic.user_params(user, :region)
    dates_interval = (start_date..end_date).to_a

    return dates_interval.count if include_sat? && include_sun? && include_bank_holidays?

    dates_interval.delete_if {|i| i.wday == 6 && !include_sat? || #delete date from array if day of week is a saturday (6)
                                  i.wday == 0 && !include_sun? || #delete date from array if day of week is a sunday (0)
                                  !include_bank_holidays? && i.holiday?(user_region.to_sym, :observed)
    }

    return dates_interval.count
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