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

  has_many :wl_custom_project_windows, :dependent => :destroy

  before_update :check_custom_allocations
  before_update :check_overtimes
  before_update :check_custom_project_windows
  before_update :check_tooltip_and_display_role_ids
  after_save :update_overlaps
  after_destroy :update_overlaps
  after_create :create_project_allocations

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true
  validates :project_id, presence: true
  validates :tooltip_role_ids, presence: true
  validates :display_role_ids, presence: true

  validate :end_date_not_before_start_date
  validate :check_custom_allocations
  validate :check_overtimes
  validate :check_custom_project_windows
  validate :check_tooltip_and_display_role_ids

  attr_accessible :start_date, :end_date, :project_id, :tooltip_role_ids, :display_role_ids

  serialize :tooltip_role_ids
  serialize :display_role_ids

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
				errors.add(:base, "Custom allocation \##{c.id} for #{c.user.name} from #{c.start_date} to #{c.end_date} needs to be moved first")
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

	def check_overtimes
		overtimes = WlUserOvertime.where(wl_project_window_id: self.id)

		overtimes.find_each do |c|
			if self.start_date > c.start_date || self.end_date < c.end_date
				errors.add(:base, "Overtime \##{c.id} for #{c.user.name} from #{c.start_date} to #{c.end_date} needs to be moved first")
			end
		end
	end

	def check_custom_project_windows
		custom_project_window = WlCustomProjectWindow.where(wl_project_window_id: self.id)

		custom_project_window.find_each do |c|
			if self.start_date > c.start_date || self.end_date < c.end_date
				errors.add(:base, "Custom Project Window for #{c.user.name} from #{c.start_date} to #{c.end_date} needs to be moved first")
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

	def check_tooltip_and_display_role_ids
		errors.add(:base, l(:error_role_id_project_window_blanck)) if tooltip_role_ids == [""] || display_role_ids == [""]
	end	

end