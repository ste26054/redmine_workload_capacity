class CreateWlCustomProjectWindows < ActiveRecord::Migration
	def change
		create_table :wl_custom_project_windows do |t|
			t.column :start_date, :date, :null => false
			t.column :end_date, :date, :null => false

			t.belongs_to :wl_project_window, index: true, :null => false
			t.belongs_to :user, index: true, :null => false
		end
	end
end