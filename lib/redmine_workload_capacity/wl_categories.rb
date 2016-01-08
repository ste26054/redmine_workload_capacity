module WlCategories

	def self.date_granularity_options 
		# [["Daily", 1], ["Weekly", 2], ["Monthly", 3], ["Quarterly", 4], ["Yearly", 5]]
		return { daily: 0, weekly: 1, monthly: 2, quarterly: 3, yearly: 4}
		
	end

end