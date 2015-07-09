module WlLogic

	def self.get_time_periods
		dates = WlProjectWindow.order(:start_date)
		from_dates = dates.map {|o| o[:start_date]}.sort.uniq
		to_dates = dates.map {|o| o[:end_date]}.sort.uniq
			
		dates_boundaries_before = []
		dates_boundaries_after = []

		from_dates.each_with_index do |period, index|
			if index > 0 && (period - 1.day) >= from_dates.first && !(period - 1.day).in?(to_dates)
				dates_boundaries_before << period - 1.day
			end
		end

		to_dates.each_with_index do |period, index|
			if index < to_dates.size - 1 && (period + 1.day) <= to_dates.last && !(period + 1.day).in?(from_dates)
				dates_boundaries_after << period + 1.day
			end
		end

		time_periods = (from_dates + to_dates + dates_boundaries_before + dates_boundaries_after).flatten.sort.each_slice(2).to_a
		time_periods.delete_if {|t| WlProjectWindow.overlaps(t[0], t[1]).empty? } 
		return time_periods
	end

	def self.generate_overlaps_table
		table = []
			self.get_time_periods.each do |overlap|
				projects_window_associated = WlProjectWindow.overlaps(overlap[0], overlap[1])
				unless projects_window_associated.empty?
					entry = {}
					entry[:start_date] = overlap[0]
					entry[:end_date] = overlap[1]
					entry[:project_window_ids] = projects_window_associated.map {|o| o.id}
					table << entry
				end
			end
		return table
	end

	def self.get_overlaps_from_db
		table = []

		WlOverlap.find_each do |overlap|
			entry = {}
			entry[:start_date] = overlap.start_date
			entry[:end_date] = overlap.end_date
			entry[:project_window_ids] = overlap.wl_project_windows.map {|o| o.id}
			table << entry
		end
		return table
	end

end