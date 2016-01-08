class RenameColumnToGrSeries < ActiveRecord::Migration
	def change
		rename_column :gr_series, :type_id, :entry_id
		rename_column :gr_series, :type_type, :entry_type
	end
end