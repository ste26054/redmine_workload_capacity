class CreateWlOverlaps < ActiveRecord::Migration
	def change
		create_table :wl_overlaps do |t|
			t.column :start_date, :date, :null => false
			t.column :end_date, :date, :null => false
		end

		create_table :wl_project_overlaps do |t|
			t.belongs_to :wl_overlap, index: true, :null => false
			t.belongs_to :wl_project_window, index: true, :null => false
		end

	end
end