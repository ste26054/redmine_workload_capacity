class CreateWlProjectAllocations < ActiveRecord::Migration
	def change
		create_table :wl_project_allocations do |t|
			t.column :percent_alloc, :integer, :null => false

			t.belongs_to :wl_project_window, index: true, :null => false
			t.belongs_to :user, index: true, :null => false
		end
	end
end