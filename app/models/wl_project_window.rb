class WlProjectWindow < ActiveRecord::Base
  unloadable
  include WlScopeExtension::Dates
  include WlCommonValidation
  include WlLogic

  belongs_to :project

  has_many :wl_user_overtime, :dependent => :destroy
  
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
  after_save :update_dashboard
  after_destroy :update_overlaps
  after_create :create_project_allocations

  validates :start_date, date: true, presence: true
  validates :end_date, date: true, presence: true
  validates :project_id, presence: true
  validates :tooltip_role_ids, presence: true
  validates :display_role_ids, presence: true
  validates :low_accept_check_limit, presence: true, numericality: true, inclusion: { in: 0..100 }
  validates :high_accept_check_limit, presence: true, numericality: true, inclusion: { in: 0..100 }
  validates :low_danger_check_limit, presence: true,  numericality: true, inclusion: { in: 0..100 }
  validates :high_danger_check_limit, presence: true,  numericality: true, inclusion: { in: 0..100 }

  validate :end_date_not_before_start_date
  validate :check_custom_allocations
  validate :check_overtimes
  validate :check_custom_project_windows
  validate :check_tooltip_and_display_role_ids
  validate :check_acceptable_danger_limits

  attr_accessible :start_date, :end_date, :project_id, :tooltip_role_ids, :display_role_ids, :low_accept_check_limit, :high_accept_check_limit, :low_danger_check_limit, :high_danger_check_limit

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

	def check_acceptable_danger_limits
		if (low_danger_check_limit.to_f <= low_accept_check_limit.to_f) || (high_accept_check_limit.to_f >= high_danger_check_limit.to_f)
			errors.add(:base, l(:error_check_limits))
		end

	end

	def update_dashboard
		changes = self.changes
		if  changes.has_key?("display_role_ids") && changes["display_role_ids"][0] != nil

			new_role_list = changes["display_role_ids"][1]
			old_role_list = changes["display_role_ids"][0]
	
			new_user_ids_list = user_ids_from_role_ids_list(new_role_list)
			old_user_ids_list = user_ids_from_role_ids_list(old_role_list)

			user_ids_list_to_add = []
			user_ids_list_to_add = new_user_ids_list - old_user_ids_list
			user_ids_list_to_remove = []
			user_ids_list_to_remove = old_user_ids_list - new_user_ids_list

			unless user_ids_list_to_add.empty?
				# there is new added, please create new project allocation for them
				user_ids_list_to_add.each do |user_id|
					parameters = {percent_alloc: 100, user_id: user_id, wl_project_window_id: self.id}
					obj =  WlProjectAllocation.new(parameters)
					obj.save
				end	
				
			end
			unless user_ids_list_to_remove.empty?
				# need to delete users that are not called
				# project allocation, custom project window if exists, custom allocation if exists and overtime if exists
				# the order of deleting actions on different tables is quite important
	
				user_ids_list_to_remove.each do |user_id|
					parameters = {wl_project_window_id: self.id, user_id: user_id}

					#Custom Project Allocation if exists
					WlCustomAllocation.where(parameters).destroy_all

					#Overtime if exists
					WlUserOvertime.where(parameters).destroy_all

					#Custom project window if exists
					WlCustomProjectWindow.where(parameters).destroy_all

					#Default Project Allocation
					WlProjectAllocation.find_by(parameters).destroy
				end	
			end
		
		end
	end


private
def user_ids_from_role_ids_list(role_ids_list)
	wl_users = []
	unless role_ids_list && role_ids_list.empty?
		 	role_ids_list.each do |role_id|
		 		role = Role.find(role_id)
		 		wl_users << WlUser.users_for_project_role(self.project, role)
		 		wl_users.flatten(1)
		 	end
		 	wl_users = wl_users.flatten.uniq
	end
	return wl_users.map{ |wl_user| wl_user.id}
end

	

end