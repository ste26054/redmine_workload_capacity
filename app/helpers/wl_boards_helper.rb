module WlBoardsHelper

	def link_to_project_workload(project)
		#return "#{<%= link_to 'Edit', edit_project_user_wl_custom_allocation_path(project, member.user, custom_alloc.first) %>}".html_safe
		link_to(project.name, {:controller => 'wl_boards', :action => 'index', :project_id => project.id})
	end

	def render_details_tooltip(details, member)
		output = "".html_safe
		details.each do |element|
			output << "<strong>#{link_to_project_workload(element[:wl_project_window].project)}</strong>:".html_safe
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
		output << "#{alloc_btw} (#{hours_week.round(1)}h/week)"
		output << "<strong> *</strong>".html_safe if overtimes_exist 
		return output
	end

	def render_member_overtime(member, hours, start_date, end_date)
		output = "".html_safe
		hours_per_week = member.user.weekly_working_hours
		time_period = (end_date - start_date).to_i + 1
		extra_hours_per_week = hours.to_f / time_period * 5.0
		extra_percent_per_week =  (extra_hours_per_week * 100.0) / hours_per_week
		output << "+#{extra_percent_per_week.round(1)}% (+#{extra_hours_per_week.round(1)}h/week)".html_safe
		return output
	end
	
end