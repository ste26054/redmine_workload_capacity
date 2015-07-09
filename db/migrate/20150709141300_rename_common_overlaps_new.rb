class RenameCommonOverlapsNew < ActiveRecord::Migration
	def change
		rename_table :wl_overlaps_project_overlaps, :wl_common_windows
	end
end