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

	def custom_alloc_uniq_within_period
	  	overlaps = self.class.for_user(user_id).overlaps(start_date, end_date)

	  	overlaps.find_each do |o|
	  		errors.add(:base, "Error: overlap found. Id: #{o.id} From: #{o.start_date}, To: #{o.end_date}")
	  	end
	end
end