module WlCheckMailerTriggers

	# Checks renewal for any active user
	def self.check_current_week#(current_date)
		current_date = Date.new(2015,2,8)#Date.today
		start_week = current_date.beginning_of_week
		end_week = current_date.end_of_week
		projects_with_wl_members = WlProjectWindow.all.overlaps(current_date, current_date).map{|pw| pw.project}
		projects_with_wl_members.each do |project|
			project.wl_members.each do |wl_member| 
				ratio = wl_member.get_check_ratio(start_week, end_week)
				self.check_ratio_for_mail(project, wl_member.user, ratio, 0.05, 0.1)
			end
		end	
	end


	def self.check_ratio_for_mail(project, wl_user, ratio, acceptable_threshold = 0.05, danger_threshold = 0.1)
		# danger_threshold has to be bigger than acceptable_threshold
		red_limit_minus = (1.0-danger_threshold).to_f
		red_limit_plus = (1.0+danger_threshold).to_f

		green_limit_minus = (1.0-acceptable_threshold).to_f
		green_limit_plus = (1.0+acceptable_threshold).to_f
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