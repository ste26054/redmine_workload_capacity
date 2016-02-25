module WlCategories

	def self.date_granularity_options 
		# [["Daily", 1], ["Weekly", 2], ["Monthly", 3], ["Quarterly", 4], ["Yearly", 5]]
		return { daily: 0, weekly: 1, monthly: 2, quarterly: 3, yearly: 4}
		
	end

	def self.operation_options
		#return { sum: 0, average: 1}
		return { sum: 0, average: 1}
	end


	def self.array_date_period(start_date, end_date, granularity )
		period = start_date..end_date 
		category_data=[]

		case granularity
		when 0 # daily
			category_data = period.map{|a| a.strftime('%a %d %b %Y')}
		when 1 # weekly
			hash_period = self.hash_date_period(start_date, end_date, granularity) 
			category_data = hash_period.map{|a| "#{a.first.last} - Week #{a.first.first}"}
		when 2 # monthly
			hash_period = self.hash_date_period(start_date, end_date, granularity) 
			category_data = hash_period.map{|a| "#{a.first.last} - #{Date::MONTHNAMES[a.first.first]}"}
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
		when 1 # weekly
			#hash_period = period.group_by(&:cweek)
			hash_period = period.group_by{|d| [d.cweek, d.year]}
		when 2 # monthly
			#hash_period = period.group_by(&:month)
			hash_period = period.group_by{|d| [d.month, d.year]}
		when 3 # quarterly
			hash_period = period.group_by(&:beginning_of_quarter)
			#hash_period = period.group_by{|d| [d.beginning_of_quarter, d.year]}
		when 4 # yearly
			hash_period = period.group_by(&:year)
		else # when 0 #daily
			hash_period = Hash[period.map.with_index{|x,i| [i+1, [x,x]]}]
		end
		return hash_period
	end

	def self.get_array_data(gr_cat)
		category_data = []

		unless gr_cat.nil?
			#initialisation
			start_period = gr_cat.properties[:start_date].to_date
			end_period = gr_cat.properties[:end_date].to_date
			granularity = gr_cat.properties[:granularity].to_i

			#calculation abscisse
			category_data = WlCategories.array_date_period(start_period, end_period, granularity)

		end

		return category_data
	end

end