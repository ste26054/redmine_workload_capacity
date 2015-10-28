module WlBoardsHelper

	def link_to_project_workload(project)
		#return "#{<%= link_to 'Edit', edit_project_user_wl_custom_allocation_path(project, member.user, custom_alloc.first) %>}".html_safe
		return link_to(project.name, {:controller => 'wl_boards', :action => 'index', :project_id => project.id})
	end

	def render_details_tooltip(details, member)
		output = "".html_safe

		details.each do |element|
			member_project = element[:wl_project_window].project.id == member.project.id

			output << '<strong>'.html_safe if member_project
			output << "#{link_to_project_workload(element[:wl_project_window].project)}:".html_safe
			output << '</strong>'.html_safe if member_project
			output << " #{element[:percent_alloc]}%".html_safe
			output << " (#{member.user.weekly_working_hours * element[:percent_alloc] / 100.0}h/week)</br>".html_safe
			
			project = Project.find(element[:wl_project_window].project.id)
			role = nil
			role_id_list = element[:wl_project_window].tooltip_role_ids
			wl_role_user_names = ""
			if role_id_list.is_a?(Array)
				role_id_list.each do |role_id|
					if Role.exists?(role_id)
						role = Role.find(role_id)
						wl_role_user_names = WlUser.users_for_project_role(project, role).map{ |user| link_to	user.firstname+" "+user.lastname, User.find(user.id)}.join(', ')
					
						unless role.nil?
							output << '<strong>'.html_safe if member_project
							output << " #{role.name}:  ".html_safe
							output << '</strong>'.html_safe if member_project
							output << "#{wl_role_user_names}</br>".html_safe 
						end
					end
				end
			end
		end
		return output
	end

	def render_smart_allocation_tooltip(custom_alloc)
		output = "".html_safe
		output << "<strong>Allocate:</strong> #{custom_alloc[:percent_alloc]}%<br/>".html_safe
		output << "<strong>From:</strong> #{format_date(custom_alloc[:start_date])}<br/>".html_safe
		output << "<strong>To:</strong> #{format_date(custom_alloc[:end_date])}".html_safe
		return output
	end

	def render_member_project_allocation(member, start_date, end_date, overtime_notification = true)
		alloc_btw = member.wl_project_allocation_between(start_date, end_date)
		hours_week = member.user.weekly_working_hours * alloc_btw / 100.0
		if overtime_notification
			overtimes_exist = !WlUserOvertime.where(user_id: member.user_id, wl_project_window_id: member.project.wl_project_window.id).overlaps(start_date, end_date).empty?
		else
			overtimes_exist = false
		end
		output = "".html_safe
		output << '<span class="overtime">'.html_safe if overtimes_exist
		output << "#{alloc_btw}% (#{hours_week.round(1)}h/week)"
		output << "<strong> *</strong>".html_safe if overtimes_exist
		output << '</span>'.html_safe if overtimes_exist
		return output
	end

	def dashboard_row(member, start_date, end_date, total_alloc, details, overtime = nil)		
		
		output = "".html_safe

		output << '<tr><td colspan="3"></td>'.html_safe
		output << "<td>#{format_date(start_date)}</td>".html_safe
		output << "<td>#{format_date(end_date)}</td>".html_safe
		output << "<td>#{render_member_project_allocation(member, start_date, end_date, overtime.nil?)}</td>".html_safe
		output << '<td><div class="tooltip">'.html_safe
		output << "#{total_alloc}%".html_safe
		output << '<span class="tip">'.html_safe
		output << "#{render_details_tooltip(details, member)}</span></div></td>".html_safe
		unless overtime.nil?
			output << '<td><div class="tooltip">'.html_safe
			output << "#{render_member_overtime(member, overtime)}".html_safe
			output << '<span class="tip">'.html_safe
			output << "#{render_member_overtime_tooltip(overtime)}</span></div></td></tr>".html_safe
		else
			output << '<td></td></tr>'.html_safe
		end
		return output
	end

	def render_member_overtime(member, wl_user_overtime)
		output = "".html_safe
		user_hours_per_day = member.user.weekly_working_hours / 5.0
		days_count = wl_user_overtime.overtime_days_count

		extra_hours_per_day = wl_user_overtime.overtime_hours.to_f / days_count
		extra_percent_per_day =  (extra_hours_per_day * 100.0) / user_hours_per_day
		output << '<span class="overtime">'.html_safe
		output << "+#{extra_percent_per_day.round(1)}% (+#{extra_hours_per_day.round(1)}h/day)".html_safe
		output << '</span>'.html_safe
		return output
	end

	def render_member_overtime_allocation(wl_user_overtime)
		output = "".html_safe
		output << "User Overtime (#{wl_user_overtime.overtime_hours}h)".html_safe

		tab_incl = []
		tab_incl << 'Saturdays'.html_safe if wl_user_overtime.include_sat?
		tab_incl << 'Sundays'.html_safe if wl_user_overtime.include_sun?
		tab_incl << 'Bank Holidays'.html_safe if wl_user_overtime.include_bank_holidays?

		output << '<strong> Include: '.html_safe unless tab_incl.empty?
		output << tab_incl.join(', '.html_safe)
		output << '</strong>'.html_safe
		return output
	end

	def render_member_overtime_tooltip(wl_user_overtime)
		extra_hours_per_day = (wl_user_overtime.overtime_hours.to_f / wl_user_overtime.overtime_days_count).round(1)
		user_hours_per_day = (wl_user_overtime.user.weekly_working_hours / 5.0).round(1)
		extra_percent_per_day =  ((extra_hours_per_day * 100.0) / user_hours_per_day).round(1)
		output = "".html_safe
		output << "<strong>User Working Hours:</strong> #{user_hours_per_day}h/day<br/>".html_safe
		output << "<strong>Actual Working days:</strong> #{wl_user_overtime.overtime_days_count}<br/>".html_safe
		output << "<strong>Overtime:</strong> #{wl_user_overtime.overtime_hours} hours / #{wl_user_overtime.overtime_days_count} days = #{extra_hours_per_day}h/day<br/>".html_safe
		output << "<strong>Overtime represents:</strong> #{extra_hours_per_day} / #{user_hours_per_day} = #{extra_percent_per_day}% of User Working Hours per day".html_safe
		return output
	end

	def display_new_label(member)

		output = "".html_safe

		created_date = (Date.today - member.wl_project_allocation.created_at.to_date).to_i if member.wl_project_allocation.created_at 
		#if !member.wl_project_allocation.updated_at 
		
		if created_date && created_date < 7 
			updated_date = (member.wl_project_allocation.updated_at.to_time - member.wl_project_allocation.created_at.to_time).to_i if !member.wl_project_allocation.updated_at.nil? 
			if updated_date == 0.0 
  				output <<  "#{image_tag "new.gif", :plugin => "redmine_workload_capacity"}".html_safe
  			end
		end 


		return output
	end

  	def index_tabs        
  
     tabs = [
        {:name => 'wldashboard', :partial => 'wl_boards/dashboard_index', :label => :label_wldashboard},
        {:name => 'wlconfigure', :partial => 'wl_boards/configure_index', :label => :label_wlconfigure},
        {:name => 'wlcheck', :partial => 'wl_boards/check_index', :label => :label_wlcheck}
         ]
    end 
end