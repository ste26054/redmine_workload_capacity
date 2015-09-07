module WlCommonValidation
	def end_date_not_before_start_date
		if end_date && start_date
		  errors.add(:base, l(:error_dates)) if end_date < start_date
		end
	end

	def dates_not_beyond_project_window
	  	if end_date && start_date
	  		errors.add(:end_date, l(:error_custom_alloc_boundary)) if end_date > wl_project_window.end_date
	  		errors.add(:start_date, l(:error_custom_alloc_boundary)) if start_date < wl_project_window.start_date
	  	end
	end

	def dates_not_beyond_custom_project_window
		custom_project_window = WlCustomProjectWindow.find_by(user_id: user.id, wl_project_window_id: wl_project_window.id)
	  	if custom_project_window && end_date && start_date
	  		errors.add(:end_date, l(:error_custom_alloc_boundary_c, :from => custom_project_window.start_date, :to => custom_project_window.end_date)) if end_date > custom_project_window.end_date
	  		errors.add(:start_date, l(:error_custom_alloc_boundary_c, :from => custom_project_window.start_date, :to => custom_project_window.end_date)) if start_date < custom_project_window.start_date
	  	end
	end	

	def custom_alloc_uniq_within_period
	  	overlaps = self.class.overlaps(start_date, end_date)

	  	overlaps.find_each do |o|
	  		unless o.id == self.id
	  			errors.add(:base, "Error: overlap found. Id: #{o.id} From: #{o.start_date}, To: #{o.end_date}")
	  		end
	  	end
	end

	def custom_alloc_per_user_uniq_within_period
	  	overlaps = self.class.where(user_id: user_id, wl_project_window_id: wl_project_window_id).overlaps(start_date, end_date)

	  	overlaps.find_each do |o|
	  		unless o.id == self.id
	  			errors.add(:base, "Error: overlap found. Id: #{o.id} From: #{o.start_date}, To: #{o.end_date}")
	  		end
	  	end
	end
end
