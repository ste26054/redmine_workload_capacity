class AddRoleToWlProjectWindows < ActiveRecord::Migration
	def change
		add_column :wl_project_windows, :role_id, :integer, :null => false
	end
end
