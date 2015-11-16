module WlCheckMailerTriggers

	# Checks renewal for any active user
	def self.check_current_week#(current_date)
		current_date = Date.today
		projects_with_wl_members = WlProjectWindow.all.overlaps(current_date, current_date).map{|pw| pw.project}
		projects_with_wl_members.each do |project|
			project.wl_members.each do |wl_member| 
				self.check_loggedtime(wl_member, current_date)
			end
		end	
	end

	def self.check_loggedtime(wl_member, date)
		wl_user = wl_member.user
		start_week = date.beginning_of_week
		end_week = date.end_of_week # the trigger should be done by the end of the week

		date_list = []
		current_date = start_week
		daily_ratio_total = 0

		overtime_table =  WlUserOvertime.where(user_id: wl_member.user_id, wl_project_window_id: wl_member.project.wl_project_window.id)
		logged_hours_table = self.get_logged_time(wl_member.user_id, wl_member.project, date)
		while current_date <= end_week
			
			logged_hours = logged_hours_table[current_date]
			logged_hours = 0 if logged_hours.nil?
			daily_alloc_hours = 0
			extra_hours_per_day = 0
			alloc_hours_total = 0

			#bank_holiday?
			unless self.holiday_date_for_user(wl_user,current_date) || current_date.cwday == 6 || current_date.cwday == 7
				daily_alloc_percent = wl_member.wl_project_allocation_between(current_date, current_date)
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

		ratio = (daily_ratio_total/date_list.size).round(2)
		
 		if (ratio <= 0.9) || (ratio >= 1.10) # RED # send notif to PM
 			pm_list = WlUser.users_for_project_role(wl_member.project, Role.find(3))
 			unless pm_list.empty?
         	 Mailer.wl_notify(pm_list, wl_member.project, {user: wl_user, ratio: ratio}).deliver
         	 #Mailer.wl_notify([User.find(159)], wl_member.project, {user: wl_user}).deliver
      		end

        elsif  ((ratio > 0.90) && (ratio < 0.95)) || ((ratio > 1.05) && (ratio < 1.10)) # GREEN # send notif to user and PM
          
        	pm_list = WlUser.users_for_project_role(wl_member.project, Role.find(3))
        	sender_list = pm_list
        	sender_list << wl_user
        	unless sender_list.empty?
          		Mailer.wl_notify(sender_list,  wl_member.project, {user: wl_user, ratio: ratio}).deliver
          	end
        end

	end

	def self.get_logged_time(user_id, project, current_date)
		User.current = User.find(user_id)
		TimeEntryQuery.new(project: project).results_scope.where(user_id: user_id, :spent_on => current_date.beginning_of_week.. current_date.end_of_week).group(:spent_on).sum(:hours)
    end

    def self.holiday_date_for_user(user, date)
      region = user.leave_preferences.region.to_sym
      date.holiday?(region, :observed)
    end
end