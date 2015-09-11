module WlLogic

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
		#time_periods.delete_if {|t| WlProjectWindow.overlaps(t[0], t[1]).empty? } 
		return time_periods
	end

	def self.generate_overlaps_table
		table = []
		dates = WlProjectWindow.order(:start_date)
		self.get_time_periods(dates).each do |overlap|
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

	def self.generate_allocations_table(member)
		dates = []

		wl_custom_project_window = member.wl_custom_project_window

		if wl_custom_project_window == nil
			dates << member.project.wl_project_window
		else
			dates << wl_custom_project_window
		end

		custom_allocs = WlCustomAllocation.where(user_id: member.user_id, wl_project_window_id: member.project.wl_project_window.id)
			
		custom_allocs.find_each do |alloc|
			dates << alloc
		end
		table = []
		self.get_time_periods(dates).each do |time_period|
			entry = {}
			entry[:start_date] = time_period[0]
			entry[:end_date] = time_period[1]
			
			custom_allocation = custom_allocs.overlaps(time_period[0], time_period[1])
			unless custom_allocation.empty?
				entry[:percent_alloc] = custom_allocation.first.percent_alloc
			else
				unless member.wl_project_allocation == nil
					entry[:percent_alloc] = member.wl_project_allocation.percent_alloc
				else
					entry[:percent_alloc] = 100
				end
			end

			entry[:wl_project_window] = member.project.wl_project_window

			unless wl_custom_project_window == nil
				entry[:wl_custom_project_window] = wl_custom_project_window
			end

			
			
			table << entry
		end
		return table
	end

	def self.generate_allocations_table_user(user)
		dates = []

		user.wl_allocs.each do |alloc|
			if alloc[:custom_project_window] != nil
				dates << alloc[:custom_project_window]
			else
				dates << alloc[:default_alloc].wl_project_window
			end
			

			alloc[:custom_allocs].each do |custom|
				dates << custom
			end
		end

		time_periods = self.get_time_periods(dates)
		time_ranges = time_periods.map {|o| o[0]..o[1]}

		table = []

		
		time_ranges.each do |tr|
			entry = {}
			entry[:start_date] = tr.first
			entry[:end_date] = tr.last
			entry[:percent_alloc] = 0
			entry[:details] = []
			user.wl_memberships.each do |m|
				m.wl_table_allocation.each do |wtl|
					if (wtl[:start_date]..wtl[:end_date]).overlaps?(tr)
						entry[:percent_alloc] += wtl[:percent_alloc]
						entry[:details] << {
							wl_project_window: wtl[:wl_project_window], 
							wl_custom_project_window: wtl[:wl_custom_project_window], 
							percent_alloc: wtl[:percent_alloc]
						}
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

	def self.wl_member_allocation(member)
		project_window = member.project.wl_project_window
		hsh = {}
		project_alloc = member.wl_project_allocation
		#raise "project allocation not defined for user #{user.login}" if project_alloc == nil
		if project_alloc
			hsh[:project_id] = member.project.id
			hsh[:default_alloc] = project_alloc
			hsh[:custom_allocs] = []

			custom_allocs = WlCustomAllocation.where(user_id: member.user_id, wl_project_window_id: project_window.id)
			
			custom_allocs.find_each do |alloc|
				hsh[:custom_allocs] << alloc
			end

			hsh[:custom_project_window] = member.wl_custom_project_window

		end
		return hsh
	end

	def self.users_for_project_role(project, role)
		users = []
		members = project.members.to_a
		members.each do |member|
			role_ids = member.roles.map{ |role| role.id }
			if role.id.in?(role_ids)
				users << member.user
			end
		end	
		return users
	end

end