class AddCheckHighRangeToWlProjectWindows < ActiveRecord::Migration
	def change
		add_column :wl_project_windows, :high_accept_check_limit, :integer, :null => false, :default => 5
		add_column :wl_project_windows, :high_danger_check_limit, :integer, :null => false, :default => 10
	end
end
