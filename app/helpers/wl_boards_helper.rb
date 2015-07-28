module WlBoardsHelper

	def render_details_tooltip(details, member)
		output = "".html_safe
		details.each do |element|
			output << "<strong>#{link_to_project(element[:wl_project_window].project)}</strong>:".html_safe
			output << " #{element[:percent_alloc]}%".html_safe
			output << " (#{member.user.weekly_working_hours * element[:percent_alloc] / 100.0} hours pw)</br>".html_safe
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