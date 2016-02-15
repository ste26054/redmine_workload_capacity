module WlSeries

	def self.attribut_options 
		#return [ project_allocation: 0, total_allocation: 1, remaining_allocation: 2, logged_time: 3, check_ratio: 4]
		return { project_allocation: 0, total_allocation: 1, remaining_allocation: 2, logged_time: 3, check_ratio: 4, real_allocation: 5}
		
	end

	def self.operation_options
		#return { sum: 0, average: 1, min: 2, max: 3}
		return { sum: 0, average: 1, min: 2, max: 3}
	end

	def self.stacking_options
		return { no_stacking: 0, stacking: 1, percent_stacking: 2}
	end

	def self.unit_options
		#return { fte: 0, hours: 1, percent: 2}
		return { fte: 0, hours: 1, percent: 2}
	end


	def self.gr_operation(array_data, operation_type)
		calculated_data = []
		#{ sum: 0, average: 1, min: 2, max: 3}
		case operation_type 
		when 0
			calculated_data = array_data.transpose.map{|a| a.reduce(:+)}
		when 2
			calculated_data = array_data.transpose.map(&:min)
		when 3
			calculated_data = array_data.transpose.map(&:max)
		else # do average by default : when 1
			calculated_data = array_data.transpose.map{|a| a.reduce(:+) / a.size}
		end	

		return calculated_data 
	end

	def self.get_stacking_value(key)
		case key
		when 1 # stacking: normal
			return "normal"
		when 2 # stacking: percent
			return "percent"
		else # stacking undefined
			return ""
		end
			
	end

	def self.get_unit_value(key)
		unit_value = ""
		case key
		when 0 # fte
			unit_value = " FTE"
		when 1 # hours
			unit_value = " h"
		when 2 # percent
			unit_value = " %"
		else # none
			unit_value = ""
		end
		return unit_value
	end


	def self.get_array_data(project, gr_cat)
		series_data = []

		unless gr_cat.nil?
			#initialisation
			
			start_period = gr_cat.properties[:start_date].to_date
			end_period = gr_cat.properties[:end_date].to_date
			granularity = gr_cat.properties[:granularity].to_i
			category_operation = gr_cat.properties[:operation].to_i
			graph_id = gr_cat.gr_graph_id
			
			#calcul series
			gr_ser_list = GrSeries.where(gr_graph_id: graph_id)

			unless gr_ser_list.blank?
				category_hash = WlCategories.hash_date_period(start_period, end_period, granularity)

				gr_ser_list.each do |series|

					#single series initialisation
					final_entry_data = []
					series_color = series.properties[:color]
					attribut_type = series.properties[:attribut].to_i
					operation_type = series.properties[:operation]
					stacking_key = series.properties[:stacking]
					stacking_value = ""
					unless stacking_key.nil?
						stacking_value = self.get_stacking_value(stacking_key.to_i)
					end

					unit_key = series.properties[:unit]
					unit_value = ""
					unless unit_key.nil?
						unit_key = unit_key.to_i
						unit_value = self.get_unit_value(unit_key)
					else
						unit_key = 0
					end

					if operation_type.nil?
						# no operation = only one entry and this entry is an user
						gr_entry = GrEntry.find_by(gr_series_id: series.id)
						#gr_member = project.wl_members.select{|wl_m| wl_m.user_id == gr_entry.entry_id }.first
							#distrinct when attribut_type is 1 :
						if attribut_type == 1 # total_allocation
							#gr_members = []
							gr_members = gr_entry.entry.members.select{|m| m.wl_member? }
							
							gr_members.each do |gr_member|
								entry_data = []
								entry_data = gr_member.gr_entry_data(start_period, end_period, category_hash, granularity, 0, category_operation, unit_key)
								unless entry_data.blank?
									#data_array << entry_data
									title = "#{series.name}-#{gr_member.project.name}"
									series_data << {name: title, type: series.chart_type, borderColor: "##{series_color}", borderWidth: 1, tooltip: { pointFormat:  '{series.name}: <b>{point.y}</b><br/>Total: {point.stackTotal}', valueSuffix: unit_value }, data: entry_data, stack: "total_#{series.id}",  stacking: stacking_value}

								end
								
							end
							
						else
							gr_member = project.wl_members.select{|wl_m| wl_m.user_id == gr_entry.entry_id }.first
							final_entry_data = gr_member.gr_entry_data(start_period, end_period, category_hash, granularity, attribut_type, category_operation, unit_key)
					
						end
					else
						#if there are an operation then = either one or multiple role(s), or multiple users
						gr_entries = GrEntry.where(gr_series_id: series.id)
						gr_members = []
						if gr_entries.first.entry_type == "Role"
							gr_entries.each do |gr_entry|
							 gr_members += WlMember.members_for_project_role(project,gr_entry.entry_id)
							end
						else
							gr_entries.each do |gr_entry|
								gr_members << project.wl_members.select{|wl_m| wl_m.user_id == gr_entry.entry_id }.first
							end
						end
						data_array = []
						gr_members.each do |gr_member|
							entry_data = []
							entry_data = gr_member.gr_entry_data(start_period, end_period, category_hash, granularity, attribut_type, category_operation, unit_key)
							unless entry_data.blank?
								data_array << entry_data
							end
						end
						final_entry_data = self.gr_operation(data_array, operation_type.to_i)
					end

					if operation_type.nil? && attribut_type == 1
						#already done

					else
						series_data << {name: series.name, type: series.chart_type, color: "##{series_color}", tooltip: {valueSuffix: unit_value}, data: final_entry_data, stack: "attribut#{attribut_type}", stacking: stacking_value}
					end
				end
				
			end
			
		end
		return series_data
	end

end