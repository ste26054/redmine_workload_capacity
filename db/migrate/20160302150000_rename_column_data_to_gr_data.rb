class RenameColumnDataToGrData < ActiveRecord::Migration
	def change
		rename_column :gr_data, :data, :storage_data
	end
end