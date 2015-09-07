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

	def render_member_project_allocation(member, start_date, end_date)
		alloc_btw = member.wl_project_allocation_between(start_date, end_date)
		hours_week = member.user.weekly_working_hours * alloc_btw / 100.0
		overtimes_exist = !WlUserOvertime.where(user_id: member.user_id, wl_project_window_id: member.project.wl_project_window.id).overlaps(start_date, end_date).empty?
		output = "".html_safe
		output << '<span class="overtime">'.html_safe if overtimes_exist
		output << "#{alloc_btw} (#{hours_week.round(1)}h/week)"
		output << "<strong> *</strong>".html_safe if overtimes_exist
		output << '</span>'.html_safe if overtimes_exist
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

	def link_to_custom_project_window(project, user)
		obj = WlCustomProjectWindow.find_by(user_id: user.id, wl_project_window_id: project.wl_project_window)

		if obj
			return link_to "Edit Custom Project Window (#{format_date(obj.start_date)} - #{format_date(obj.end_date)})", edit_project_user_wl_custom_project_window_path(project, user), :class => 'icon icon-edit'
		else
			return link_to 'Add Custom Project Window', new_project_user_wl_custom_project_window_path(project, user), :class => 'icon icon-add'
		end
	end
	
end