class WlProjectWindow < ActiveRecord::Base
  unloadable
  include WlScopeExtension::Dates
  include WlCommonValidation
  include WlLogic

  belongs_to :project
  has_many :wl_common_windows, :dependent => :destroy
  has_many :wl_overlaps, :through => :wl_common_windows

  has_many :wl_project_allocations, :dependent => :destroy
  has_many :wl_custom_allocations, :dependent => :destroy

  # Should add an after_update callback to ensure that any previously created WlCustomAlloc would not be beyond the new WlProjectWindow
  after_save :update_overlaps
  after_destroy :update_overlaps

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true
  validates :project_id, presence: true

  validate :end_date_not_before_start_date

  attr_accessible :start_date, :end_date, :project_id
private

	def update_overlaps
		#if changes.has_key?("start_date") || changes.has_key?("end_date")
			WlOverlap.destroy_all
			WlLogic.generate_overlaps_table.each do |overlap|
				entry = WlOverlap.new
				entry.start_date = overlap[:start_date]
				entry.end_date = overlap[:end_date]
				entry.save
			end

			# overlaps_table_new = WlLogic.generate_overlaps_table
			# overlaps_table_db = WlLogic.get_overlaps_from_db

			# identities = overlaps_table_new & overlaps_table_db
			# to_add = overlaps_table_new - identities
			# to_remove = overlaps_table_db - identities

			# to_remove.each do |overlap|
			# 	entry = WlOverlap.find_by(start_date: overlap[:start_date], end_date: overlap[:end_date]).destroy
			# end

			# to_add.each do |overlap|
			# 	entry = WlOverlap.new
			# 	entry.start_date = overlap[:start_date]
			# 	entry.end_date = overlap[:end_date]
			# 	entry.save
			# end
		#end
	end

	# def delete_overlaps
	# 	WlOverlap.destroy_all
	# end
end