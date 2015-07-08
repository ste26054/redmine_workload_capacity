module WlLogic

	def self.get_overlaps
		dates = WlProjectWindow.order(:start_date)
		from_dates = dates.map {|o| o[:start_date]}.sort.uniq
		to_dates = dates.map {|o| o[:end_date]}.sort.uniq
			
		dates_boundaries_before = []
		dates_boundaries_after = []

		from_dates.each_with_index do |period, index|
			if index > 0 && (period - 1.day) >= from_dates.first
				dates_boundaries_before << period - 1.day
			end
		end

		to_dates.each_with_index do |period, index|
			if index < to_dates.size - 1 && (period + 1.day) <= to_dates.last
				dates_boundaries_after << period + 1.day
			end
		end

		return (from_dates + to_dates + dates_boundaries_before + dates_boundaries_after).flatten.sort.each_slice(2).to_a
	end

end