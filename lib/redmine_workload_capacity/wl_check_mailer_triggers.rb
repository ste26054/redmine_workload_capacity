module WlCheckMailerTriggers

	# Checks renewal for any active user
	def self.check_current_week#(current_date)
		current_date = Date.today
		start_week = current_date.beginning_of_week
		end_week = current_date.end_of_week
		projects_with_wl_members = WlProjectWindow.all.overlaps(start_week, end_week).map{|pw| pw.project}
		projects_with_wl_members.each do |project|
			project.wl_members.each do |wl_member| 
				ratio = wl_member.get_check_ratio(start_week, end_week)
				low_accept_threshold = project.wl_project_window.low_accept_check_limit.to_f/100
				high_accept_threshold = project.wl_project_window.high_accept_check_limit.to_f/100
				low_danger_threshold = project.wl_project_window.low_danger_check_limit.to_f/100
				high_danger_threshold = project.wl_project_window.high_danger_check_limit.to_f/100
				self.check_ratio_for_mail(project, wl_member.user, ratio, low_accept_threshold, high_accept_threshold, low_danger_threshold, high_danger_threshold)
			end
		end	
	end


	def self.check_ratio_for_mail(project, wl_user, ratio, low_accept_threshold, high_accept_threshold, low_danger_threshold, high_danger_threshold)
		
		unless ratio.nil?
			red_limit_minus = 1.0-low_danger_threshold
			red_limit_plus = 1.0+high_danger_threshold

			green_limit_minus = 1.0-low_accept_threshold
			green_limit_plus = 1.0+high_accept_threshold
			ratio = ratio.to_f 

			if (ratio <= red_limit_minus) || (ratio >= red_limit_plus) # RED # send notif to PM
	 			pm_list = WlUser.users_for_project_role(project, Role.find(3))
	 			unless pm_list.empty?
	         	 Mailer.wl_notify(pm_list, project, {user: wl_user, ratio: ratio}).deliver
	      		end

	        elsif  ((ratio > red_limit_minus) && (ratio < green_limit_minus)) || ((ratio > green_limit_plus) && (ratio < red_limit_plus)) # GREEN # send notif to user and PM
	          
	        	pm_list = WlUser.users_for_project_role(project, Role.find(3))
	        	sender_list = pm_list
	        	sender_list << wl_user
	        	unless sender_list.empty?
	          		Mailer.wl_notify(sender_list,  project, {user: wl_user, ratio: ratio}).deliver
	          	end
	        end
	    end
    end

end