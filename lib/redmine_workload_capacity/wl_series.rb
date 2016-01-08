module WlSeries

	def self.attribut_options 
		#return [["Project Allocation", 1], ["Total Allocation", 2], ["Remaining Allocation", 3], ["Logged Time", 4], ["Check Ratio", 5]]
		return { project_allocation: 0, total_allocation: 1, remaining_allocation: 2, logged_time: 3, check_ratio: 4}
		
	end

end