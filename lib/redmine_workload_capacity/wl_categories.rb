module WlCategories

	def self.date_granularity_options 
		# [["Daily", 1], ["Weekly", 2], ["Monthly", 3], ["Quarterly", 4], ["Yearly", 5]]
		return { daily: 0, weekly: 1, monthly: 2, quarterly: 3, yearly: 4}
		
	end


	def self.array_date_period(start_date, end_date, granularity )
		period = start_date..end_date 
		category_data=[]

		case granularity
		when 0 # daily
			category_data = period.to_a
		when 1 # weekly
			hash_period = self.hash_date_period(start_date, end_date, granularity) 
			category_data = hash_period.map{|a| "Week #{a.first}"}
		when 2 # monthly
			hash_period = self.hash_date_period(start_date, end_date, granularity) 
			category_data = hash_period.map{|a| "Month #{a.first}"}
		when 3 # quarterly
			hash_period = self.hash_date_period(start_date, end_date, granularity) 
			category_data = hash_period.map{|a| "#{a.first.year} - Quarter #{1+(a.first.month)/4}"  }
		else # 4 yearly
			hash_period = self.hash_date_period(start_date, end_date, granularity) 
			category_data = hash_period.map{|a| "Year #{a.first}"} 
		end
		return category_data
	end

	def self.hash_date_period(start_date, end_date, granularity)
		period = start_date..end_date 
 		 
		case granularity
		when 0 # daily
			hash_period = Hash[period.map.with_index{|x,i| [i+1, [x,x]]}]
			# category_data = period.to_a
		when 1 # weekly
			hash_period = period.group_by(&:cweek)
			# category_data = hash_period.map{|a| "Week #{a.first}"}
		when 2 # monthly
			hash_period = period.group_by(&:month)
			# category_data = hash_period.map{|a| "Month #{a.first}"}
		when 3 # quarterly
			hash_period = period.group_by(&:beginning_of_quarter)
			# category_data = hash_period.map{|a| "#{a.first.year} - Quarter #{1+(a.first.month)/4)}"}
		else # 4 yearly
			hash_period = period.group_by(&:year)
			# category_data = hash_period.map{|a| "Year #{a.first}"} 
		end
		return hash_period
	end

end