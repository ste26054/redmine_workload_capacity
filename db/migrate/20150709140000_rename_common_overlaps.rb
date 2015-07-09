class RenameCommonOverlaps < ActiveRecord::Migration
	def change
		rename_table :wl_project_overlaps, :wl_overlaps_project_overlaps
	end
end