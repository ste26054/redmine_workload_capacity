class RenameTooltipRoleIdsColumnToWlProjectWindows < ActiveRecord::Migration
	def change
		rename_column :wl_project_windows, :role_ids, :tooltip_role_ids
	end
end