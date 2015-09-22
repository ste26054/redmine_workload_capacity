class AddDisplayRoleIdsToWlProjectWindows < ActiveRecord::Migration
	def change
		add_column :wl_project_windows, :display_role_ids, :text, :null => false
	end
end
