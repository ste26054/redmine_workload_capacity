class WlOverlap < ActiveRecord::Base
  unloadable

  has_one :wl_project_overlap, dependent: :destroy

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true

  validate :validate_end_date_before_start_date


private
  def validate_end_date_before_start_date
    if end_date && start_date
      errors.add(:base, "Overlap error end_date < start_date") if end_date < start_date
    end
  end
end