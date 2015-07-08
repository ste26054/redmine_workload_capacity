class WlOverlap < ActiveRecord::Base
  unloadable
  include WlScopeExtension::Dates
  include WlCommonValidation

  has_many :wl_project_overlaps, dependent: :destroy


  after_save :update_overlaps

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true

  validate :end_date_not_before_start_date
  validate :custom_alloc_uniq_within_period

  attr_accessible :start_date, :end_date
private

	def update_overlaps
		projects_window_associated = WlProjectWindow.overlaps(start_date, end_date)
		projects_window_associated.find_each do |p|
			wl_project_overlap = WlProjectOverlap.new
			wl_project_overlap.wl_overlap_id = self.id
			wl_project_overlap.wl_project_window_id = p.id
			wl_project_overlap.save
		end
	end

end