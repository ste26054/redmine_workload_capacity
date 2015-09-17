class ChangeRoleColumnToWlProjectWindows < ActiveRecord::Migration
	def change
		rename_column :wl_project_windows, :role_id, :role_ids
		change_column :wl_project_windows, :role_ids, :text , :null => false
	end
end