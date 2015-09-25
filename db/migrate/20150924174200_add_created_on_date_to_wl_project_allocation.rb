class AddCreatedOnDateToWlProjectAllocation < ActiveRecord::Migration
	def change
		add_column :wl_project_allocations, :created_at, :datetime
	end
end