class WlProjectWindow < ActiveRecord::Base
  unloadable

  belongs_to :project
  attr_accessible :project_id, :start_date, :end_date

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true
  validates :project_id, presence: true

  validate :validate_end_date_before_start_date


private
  def validate_end_date_before_start_date
    if end_date && start_date
      errors.add(:base, l(:error_project_windows_dates)) if end_date < start_date
    end
  end
end