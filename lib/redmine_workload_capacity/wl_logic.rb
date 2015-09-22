module WlLogic

	# Splits multiple dates periods which may overlap into separate time periods without overlap
	# EX: Input: [{start_date: 2015-01-01, end_date: 2015-01-31}, 
	#             {start_date: 2015-01-20, end_date: 2015-02-10}]
	# Output: [{:start_date=>Thu, 01 Jan 2015, :end_date=>Mon, 19 Jan 2015}, 
	#          {:start_date=>Tue, 20 Jan 2015, :end_date=>Sat, 31 Jan 2015}, 
	#          {:start_date=>Sun, 01 Feb 2015, :end_date=>Tue, 10 Feb 2015}]
	# OK
	def self.get_time_periods(dates)

		periods = dates.map {|o| o[:start_date]..o[:end_date]}

		from_dates = dates.map {|o| o[:start_date]}.sort.uniq
		to_dates = dates.map {|o| o[:end_date]}.sort.uniq
			
		dates_boundaries_before = []
		dates_boundaries_after = []

		from_dates.each_with_index do |period, index|
			if index > 0 && (period - 1.day) >= from_dates.first && !(period - 1.day).in?(to_dates) && !periods.reject {|e| !e.cover?(period - 1.day)}.empty?
				dates_boundaries_before << period - 1.day
			end
		end

		to_dates.each_with_index do |period, index|
			if index < to_dates.size - 1 && (period + 1.day) <= to_dates.last && !(period + 1.day).in?(from_dates) && !periods.reject {|e| !e.cover?(period + 1.day)}.empty?
				dates_boundaries_after << period + 1.day
			end
		end

		time_periods = (from_dates + to_dates + dates_boundaries_before + dates_boundaries_after).flatten.sort.each_slice(2).to_a
		return time_periods.map {|p| { start_date: p[0], end_date: p[1] } }
	end

	# Generates an overlap table which gathers all defined project windows and then says which project window occurs during the different overlaps
	# OK
	def self.generate_overlaps_table
		table = []
		dates = WlProjectWindow.order(:start_date)
		self.get_time_periods(dates).each do |overlap|
			projects_window_associated = WlProjectWindow.overlaps(overlap[:start_date], overlap[:end_date])
			unless projects_window_associated.empty?
				entry = {}
				entry[:start_date] = overlap[:start_date]
				entry[:end_date] = overlap[:end_date]
				entry[:project_window_ids] = projects_window_associated.map {|o| o.id}
				table << entry
			end
		end
		return table
	end

	# Gives the allocation table for a member within a project, during his project window(s)
	def self.generate_allocations_table_member(member)
		dates = []

		wl_custom_project_windows = WlCustomProjectWindow.where(user_id: member.user.id, wl_project_window_id: member.project.wl_project_window).to_a

		if wl_custom_project_windows.empty?
			dates << member.project.wl_project_window
		else
			dates << wl_custom_project_windows
		end

		custom_allocs = WlCustomAllocation.where(user_id: member.user_id, wl_project_window_id: member.project.wl_project_window.id)
			
		dates << custom_allocs.to_a

		table = []
		self.get_time_periods(dates.flatten).each do |time_period|
			entry = {}
			entry[:start_date] = time_period[:start_date]
			entry[:end_date] = time_period[:end_date]
			
			custom_allocation = custom_allocs.overlaps(time_period[:start_date], time_period[:end_date])

			unless custom_allocation.empty?
				entry[:percent_alloc] = custom_allocation.first.percent_alloc
			else
				unless member.wl_project_allocation == nil
					entry[:percent_alloc] = member.wl_project_allocation.percent_alloc
				else
					entry[:percent_alloc] = 100
				end
			end

			custom_project_windows = wl_custom_project_windows.dup.delete_if {|c| !(c[:start_date]..c[:end_date]).overlaps?(time_period[:start_date]..time_period[:end_date])}

			entry[:wl_project_window] = member.project.wl_project_window
			entry[:wl_custom_project_windows] = custom_project_windows

			table << entry
		end
		return table
	end

	# Gives the allocation table for a user, for all his projects bound to sufficient permissions, at project window defined, the project module is activated
	def self.generate_allocations_table_user(user)
		dates = []

		user.wl_user_allocations_extract.each do |alloc|
			unless alloc[:custom_project_windows].empty?
				dates << alloc[:custom_project_windows]
			else
				dates << alloc[:default_alloc].wl_project_window
			end
		
			dates << alloc[:custom_allocs]
		end

		time_periods = self.get_time_periods(dates.flatten)
		time_ranges = time_periods.map {|o| o[:start_date]..o[:end_date]}

		table = []

		
		time_ranges.each do |tr|
			entry = {}
			entry[:start_date] = tr.first
			entry[:end_date] = tr.last
			entry[:percent_alloc] = 0
			entry[:details] = []
			user.wl_memberships.each do |m|
				WlLogic.generate_allocations_table_member(m).each do |wtl|
					if (wtl[:start_date]..wtl[:end_date]).overlaps?(tr)
						entry[:percent_alloc] += wtl[:percent_alloc]

						custom_project_windows = wtl[:wl_custom_project_windows]
						custom_project_windows.delete_if {|c| !(c[:start_date]..c[:end_date]).overlaps?(tr)}

						hsh = {
							wl_project_window: wtl[:wl_project_window], 
							wl_custom_project_windows: custom_project_windows, 
							percent_alloc: wtl[:percent_alloc]
						}

						entry[:details] << hsh
					end
				end
			end
			table << entry
		end
		
		
		return table
	end

	def self.get_overlaps_from_db
		table = []

		WlOverlap.order(:start_date).find_each do |overlap|
			entry = {}
			entry[:start_date] = overlap.start_date
			entry[:end_date] = overlap.end_date
			entry[:project_window_ids] = overlap.wl_project_windows.map(&:id)
			table << entry
		end
		return table
	end

	def self.wl_project_overlaps(project)
		window_id = project.wl_project_window.id
		return WlLogic.get_overlaps_from_db.delete_if {|o| !window_id.in?(o[:project_window_ids])}
	end

end