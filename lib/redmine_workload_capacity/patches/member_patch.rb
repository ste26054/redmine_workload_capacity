module RedmineWorkloadCapacity
	module Patches
		module  MemberPatch
			def self.included(base) # :nodoc:
		        #base.extend(ClassMethods)

		        base.send(:include, MemberInstanceMethods)

		        base.class_eval do
		          unloadable # Send unloadable so it will not be unloaded in development

		        end
		    end
		end

		module MemberInstanceMethods
			include WlLogic
			def wl_allocation
				return WlLogic.wl_member_allocation(self)
			end

			# Returns the project allocation object
			def wl_project_allocation
				return WlProjectAllocation.create_with(percent_alloc: 100).find_or_create_by(user_id: self.user_id, wl_project_window_id: self.project.wl_project_window.id)
			end

			# Returns true if the associated user has a project allocation defined
			def wl_project_allocation?
				#return self.wl_project_allocation != nil
				return true
			end

			# Returns the current project allocation table
			def wl_table_allocation
				return WlLogic.generate_allocations_table(self)
			end

			def wl_project_allocation_between(from, to)
				time_period = from..to
				table_allocs = self.wl_table_allocation
				table_periods = table_allocs

				table_periods.each_with_index do |t|
					return t[:percent_alloc] if (t[:start_date]..t[:end_date]).overlaps?(time_period) && from >= t[:start_date] && to <= t[:end_date]
				end
				return nil
			end

			# Returns the total cross project allocation table, bound to current project window
			def wl_global_table_allocation
				user_table_alloc = self.user.wl_table_allocation
				user_project_window = self.project.wl_project_window
				user_table_alloc.delete_if {|e| user_project_window.start_date > e[:end_date] || user_project_window.end_date < e[:start_date]}
				return user_table_alloc
			end

			# Returns the total remaining cross project allocation table, excluding current project allocations, bound to current project window
			def wl_remaining_table_allocation
				project_alloc = self.wl_table_allocation
				total_alloc = self.wl_global_table_allocation
				output = self.wl_global_table_allocation

				project_alloc.each do |e|
					period = e[:start_date]..e[:end_date]
					total_alloc.each_with_index do |ta, i|
						ta_period = ta[:start_date]..ta[:end_date]
						if period.overlaps?(ta_period)
							total = (ta[:percent_alloc] - e[:percent_alloc])
							total = 100 if total > 100
							output[i][:percent_alloc] = 100 - total
						end
					end
				end

				return output
			end
		end
	end
end

unless Member.included_modules.include?(RedmineWorkloadCapacity::Patches::MemberPatch)
  Member.send(:include, RedmineWorkloadCapacity::Patches::MemberPatch)
end