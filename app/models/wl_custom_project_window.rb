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
	before_destroy :check_existing_allocation
	before_destroy :check_existing_overtime

	validate :end_date_not_before_start_date
	validate :dates_not_beyond_project_window
	validate :check_custom_allocations
	validate :check_overtimes
	validate :custom_alloc_per_user_uniq_within_period
	#validate :check_existing_allocation
	#validate :check_existing_overtime

	after_create :update_project_allocation

	attr_accessible :start_date, :end_date, :wl_project_window_id, :user_id
private


	def check_custom_allocations
		custom_allocs = WlCustomAllocation.where(wl_project_window_id: self.wl_project_window.id, user_id: self.user.id)

		custom_windows = WlCustomProjectWindow.where(user_id: user_id, wl_project_window_id: wl_project_window_id)
		custom_windows = custom_windows.where.not(id: self.id)

		custom_allocs.find_each do |c_a|

			c_a_valid = false
			custom_windows.find_each do |c_w|
				#if any custom allocation is in one of the existing custom project window period
				if c_w.start_date <= c_a.start_date && c_w.end_date >= c_a.end_date
					c_a_valid = true
				end
			end 

			unless c_a_valid # if could not find a match between the custom allocation period and one of the existing custom project window period
				# have a look with the current custom project window
				unless self.start_date <= c_a.start_date && self.end_date >= c_a.end_date
					errors.add(:base, "Custom allocation \##{c_a.id} for #{c_a.user.name} from #{c_a.start_date} to #{c_a.end_date} needs to be moved first")
				end
			end

		end
	end

	def check_overtimes
		#same logic in check_custom_allocations
		overtimes = WlUserOvertime.where(wl_project_window_id: self.wl_project_window.id, user_id: self.user.id)

		custom_windows = WlCustomProjectWindow.where(user_id: user_id, wl_project_window_id: wl_project_window_id)
		custom_windows = custom_windows.where.not(id: self.id)

		overtimes.find_each do |overtime|
			
			overtime_valid = false
			custom_windows.find_each do |c_w|
				if c_w.start_date <= overtime.start_date && c_w.end_date >= overtime.end_date
					overtime_valid = true
				end
			end 

			unless overtime_valid
				unless self.start_date <= overtime.start_date && self.end_date >= overtime.end_date
					errors.add(:base, "Overtime \##{overtime.id} for #{overtime.user.name} from #{overtime.start_date} to #{overtime.end_date} needs to be moved first")
				end
			end
		end
	end

	def check_existing_allocation
		#if there is any custom allocation on the period of the current project window,
		# we need to remove first the custom allocation before removing the current project window
		custom_allocs = WlCustomAllocation.where(wl_project_window_id: self.wl_project_window.id, user_id: self.user.id)

		custom_allocs.find_each do |c_a|
			if c_a.start_date >= self.start_date && c_a.end_date <= self.end_date
				return false
			end
		end
	end

	def check_existing_overtime
		#if there is any overtime on the period of the current project window,
		# we need to remove first the overtime before removing the current project window
		overtimes = WlUserOvertime.where(wl_project_window_id: self.wl_project_window.id, user_id: self.user.id)

		overtimes.find_each do |overtime|
			if overtime.start_date >= self.start_date && overtime.end_date <= self.end_date
				return false
			end
		end
		
	end

	def update_project_allocation
    	self.user.wl_project_allocations.find_by(wl_project_window_id: wl_project_window_id).touch()
    end

end