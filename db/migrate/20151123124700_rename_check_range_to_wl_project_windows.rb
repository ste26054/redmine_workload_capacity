class RenameCheckRangeToWlProjectWindows < ActiveRecord::Migration
	def change
		rename_column :wl_project_windows, :acceptable_check_limit, :low_accept_check_limit
		rename_column :wl_project_windows, :danger_check_limit, :low_danger_check_limit
	end
end
