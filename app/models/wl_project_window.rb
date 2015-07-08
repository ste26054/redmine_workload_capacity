class WlProjectWindow < ActiveRecord::Base
  unloadable
  include WlScopeExtension::Dates
  include WlCommonValidation
  include WlLogic

  belongs_to :project
  has_many :wl_project_overlaps

  after_save :update_overlaps

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true
  validates :project_id, presence: true

  validate :end_date_not_before_start_date

  attr_accessible :start_date, :end_date, :project_id
private

	def update_overlaps
		if changes.has_key?("start_date") || changes.has_key?("end_date")
			WlOverlap.destroy_all
			WlLogic.get_overlaps.each do |overlap|
				entry = WlOverlap.new
				entry.start_date = overlap[0]
				entry.end_date = overlap[1]
				entry.save
			end
			
		end
	end
end