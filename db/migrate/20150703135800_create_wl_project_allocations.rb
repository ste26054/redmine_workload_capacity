class CreateWlProjectAllocations < ActiveRecord::Migration
	def change
		create_table :wl_project_allocations do |t|
			t.column :percent_alloc, :integer, :null => false             # Default Project allocation (%) on project duration

			t.belongs_to :wl_project_window, index: true, :null => false
			t.belongs_to :user, index: true, :null => false               # For given user
		end
	end
end