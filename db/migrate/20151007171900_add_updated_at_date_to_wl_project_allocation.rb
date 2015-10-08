class AddUpdatedAtDateToWlProjectAllocation < ActiveRecord::Migration
	def change
		add_column :wl_project_allocations, :updated_at, :datetime
	end
end