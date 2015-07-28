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
	
end