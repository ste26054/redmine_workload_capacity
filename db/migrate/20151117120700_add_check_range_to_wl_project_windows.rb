class AddCheckRangeToWlProjectWindows < ActiveRecord::Migration
	def change
		add_column :wl_project_windows, :acceptable_check_limit, :integer, :null => false, :default => 5
		add_column :wl_project_windows, :danger_check_limit, :integer, :null => false, :default => 10
	end
end
