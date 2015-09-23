class WlCustomProjectWindow < ActiveRecord::Base
	unloadable
	include WlScopeExtension::Dates
	include WlCommonValidation
	
	belongs_to :wl_project_window
	belongs_to :user

	validates :start_date, date: true, presence: true
  	validates :end_date, date: true, presence: true
  	validates :wl_project_window_id, presence: true
  	validates :user_id, presence: true
  	before_update :check_custom_allocations
	before_update :check_overtimes

	validate :end_date_not_before_start_date
	validate :dates_not_beyond_project_window
	validate :check_custom_allocations
	validate :check_overtimes
	validate :custom_alloc_per_user_uniq_within_period

	attr_accessible :start_date, :end_date, :wl_project_window_id, :user_id
private


	def check_custom_allocations
		custom_allocs = WlCustomAllocation.where(wl_project_window_id: self.wl_project_window.id, user_id: self.user.id)

		custom_windows = WlCustomProjectWindow.where(user_id: user_id, wl_project_window_id: wl_project_window_id)

		custom_allocs.find_each do |c_a|

			c_a_valid = false
			custom_windows.find_each do |c_w|
				if c_w.start_date <= c_a.start_date && c_w.end_date >= c_a.end_date
					c_a_valid = true
				end
				
			end 

			unless c_a_valid
				unless self.start_date <= c_a.start_date && self.end_date >= c_a.end_date
					errors.add(:base, "Custom allocation \##{c_a.id} for #{c_a.user.name} from #{c_a.start_date} to #{c_a.end_date} needs to be moved first")
				end
			end




			#if self.start_date > c_a.end_date || self.end_date < c_a.start_date
			#	errors.add(:base, "Custom allocation \##{c.id} for #{c.user.name} from #{c.start_date} to #{c.end_date} needs to be moved first")
			#else
			#	if self.start_date > c.start_date
		  	#		c_a.update(start_date: self.start_date)
			#	end
#
			#	if self.end_date < c.end_date
			#		c_a.update(end_date: self.end_date)
			#	end
			#end


		end
	end

	def check_overtimes
		overtimes = WlUserOvertime.where(wl_project_window_id: self.wl_project_window.id, user_id: self.user.id)

		overtimes.find_each do |c|
			if self.start_date > c.start_date || self.end_date < c.end_date
				errors.add(:base, "Overtime \##{c.id} for #{c.user.name} from #{c.start_date} to #{c.end_date} needs to be moved first")
			end
		end
	end

end