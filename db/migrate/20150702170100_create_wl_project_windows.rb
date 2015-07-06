class CreateWlProjectWindows < ActiveRecord::Migration
	def change
		create_table :wl_project_windows do |t|
			t.column :start_date, :date, :null => false         # Project start date
			t.column :end_date, :date, :null => false           # Project end date

			t.belongs_to :project, index: true, :null => false
		end
	end
end