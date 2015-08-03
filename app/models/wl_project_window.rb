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

  before_update :check_custom_allocations
  after_save :update_overlaps
  after_destroy :update_overlaps
  after_create :create_project_allocations

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true
  validates :project_id, presence: true

  validate :end_date_not_before_start_date
  validate :check_custom_allocations

  attr_accessible :start_date, :end_date, :project_id
private

	def update_overlaps
		WlOverlap.destroy_all
		WlLogic.generate_overlaps_table.each do |overlap|
			entry = WlOverlap.new
			entry.start_date = overlap[:start_date]
			entry.end_date = overlap[:end_date]
			entry.save
		end
		self.project.wl_reload
	end

	def check_custom_allocations
		custom_allocs = WlCustomAllocation.where(wl_project_window_id: self.id)

		custom_allocs.find_each do |c|

			if self.start_date > c.end_date || self.end_date < c.start_date
				errors.add(:base, "Custom allocation \##{c.id} from #{c.start_date} to #{c.end_date} needs to be deleted first")
			else
				if self.start_date > c.start_date
		  			c.update(start_date: self.start_date)
				end

				if self.end_date < c.end_date
					c.update(end_date: self.end_date)
				end
			end
		end
	end

	def create_project_allocations
		wl_members  = self.project.wl_members
		wl_members.each do |m|
			parameters = {percent_alloc: 100, user_id: m.user_id, wl_project_window_id: self.id}
			obj =  WlProjectAllocation.new(parameters)
			obj.save
		end
	end
end