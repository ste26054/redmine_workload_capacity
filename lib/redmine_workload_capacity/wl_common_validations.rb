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
		custom_project_windows = WlCustomProjectWindow.where(user_id: user.id, wl_project_window_id: wl_project_window.id).to_a
	  	
	  	valid_date = 0
	  	start_valid = 0
	  	end_valid = 0
		unless custom_project_windows.empty?
	  		custom_project_windows.each do |custom_project_window|
	  			start_local_valid = false
	  			end_local_valid = false
	  			if end_date && start_date
	  				if start_date >= custom_project_window.start_date && start_date <= custom_project_window.end_date 
	  					start_local_valid = true
	  					start_valid +=1
	  				else
	  					start_local_valid = false
	  				end	
	  				if end_date >= custom_project_window.start_date && end_date <= custom_project_window.end_date
						end_local_valid = true
						end_valid +=1
					else
						end_local_valid = false
	  				end	
	  				if start_local_valid && end_local_valid 
	  					valid_date +=1
	  				end
	  			end
	  		end
			errors.add( "End date", l(:error_custom_alloc_boundary_c)) if valid_date == 0 && end_valid == 0
			errors.add( "Start date", l(:error_custom_alloc_boundary_c)) if valid_date == 0 && start_valid == 0
		
			errors.add( "" , l(:error_not_valid_date)) if valid_date == 0 && end_valid > 0 && start_valid > 0
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
