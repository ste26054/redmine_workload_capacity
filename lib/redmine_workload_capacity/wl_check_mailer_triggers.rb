module WlCheckMailerTriggers

	# Checks renewal for any active user
	def self.check_current_week(current_date)
		
		projects_with_wl_members = WlProjectWindow.all.overlaps(current_date, current_date).map{|pw| pw.project}
		projects_with_wl_members.each do |project|
			project.wl_members.each do |wl_member| 
				check_loggedtime(wl_member, current_date)
			end
		end	
	end

	def self.check_loggedtime(wl_member, date)
		wl_user = wl_member.user
		start_week = date.beginning_of_week
		end_week = date # the trigger should be done by the end of the week

		date_list = []
		current_date = start_week
		alloc_hours_total = 0

		overtime_table =  WlUserOvertime.where(user_id: wl_member.user_id, wl_project_window_id: wl_member.project.wl_project_window.id)
		while current_date < end_week
			daily_alloc_hours = 0
			extra_hours_per_day = 0
			#bank_holiday?
			unless holiday_date_for_user(wl_user,current_date)
				#alloc time value for the week
				daily_alloc_percent = wl_member.wl_project_allocation_between(current_date, current_date)
				daily_alloc_hours  = daily_alloc_percent/(100*5)
				#alloc_hours_total += daily_alloc_hours
			end

			#overtime?
			unless overtime_table.empty?
		      overtime = overtime_table.overlaps(current_date, current_date).first
		    else
		      overtime = nil
		    end

		    unless overtime.nil?
		      extra_hours_per_day = (overtime.overtime_hours.to_f / overtime.overtime_days_count).round(1)
		      #alloc_hours_total+= extra_hours_per_day
		     end

		    if extra_hours_per_day!=0 || daily_alloc_hours!=0
		    	alloc_hours_total+= extra_hours_per_day + daily_alloc_hours
		    	date_list << current_date
		    end

			#ratio divided by the number of working days
			current_date = current_date+1
		end
		#logged time value for the project and for the week
		logged_hours_total = get_logged_time(wl_member.user_id, wl_member.project, date_list)
		#check
		ratio = (logged_hours_total/alloc_hours_total)
		output = "Ratio : #{ratio} ______ logged: #{logged_hours_total} ______ alloc : #{alloc_hours_total}"
			#if ratio is higher then send a notificiation to PM

		return output

	end

	def self.get_logged_time(user_id, project, date_list)
	  TimeEntryQuery.new(project: project).results_scope.where(user_id: user_id, spent_on: date_list).sum(:hours)
    end


    def self.holiday_date_for_user(user, date)
      region = user.leave_preferences.region.to_sym
      date.holiday?(region, :observed)
    end
end