module WlMember
	
	def get_check_ratio(from_date, to_date)
		wl_user = self.user
		wl_project = self.project
		start_week = from_date
		end_week = to_date # the trigger should be done by the end of the week

		date_list = []
		current_date = start_week
		daily_ratio_total = 0
		ratio = 0

		overtime_table =  WlUserOvertime.where(user_id: self.user_id, wl_project_window_id: wl_project.wl_project_window.id)
		logged_hours_table = wl_user.get_logged_time(wl_project, start_week, end_week)

	
		while current_date <= end_week
			
			logged_hours = logged_hours_table[current_date]
			logged_hours = 0 if logged_hours.nil?
			daily_alloc_hours = 0
			extra_hours_per_day = 0
			alloc_hours_total = 0

			#bank_holiday?
			unless wl_user.holiday_date_for_user(current_date) || current_date.cwday == 6 || current_date.cwday == 7
				daily_alloc_percent = self.wl_project_allocation_between(current_date, current_date)
				daily_alloc_hours  = (wl_user.weekly_working_hours*daily_alloc_percent)/(100*5)
			end

			#overtime?
			unless overtime_table.empty?
		      overtime = overtime_table.overlaps(current_date, current_date).first
		    else
		      overtime = nil
		    end

		    unless overtime.nil?
		      extra_hours_per_day = (overtime.overtime_hours.to_f / overtime.overtime_days_count).round(1)
		  	end

		    unless extra_hours_per_day==0 && daily_alloc_hours==0
		    	alloc_hours_total= extra_hours_per_day + daily_alloc_hours
		    	date_list << current_date
		    end

		    daily_ratio_total += logged_hours/alloc_hours_total unless alloc_hours_total == 0
				    
			current_date = current_date+1
		end

		unless date_list.empty?
			ratio = (daily_ratio_total/date_list.size).round(2)
		end

 		return ratio

	end


end
