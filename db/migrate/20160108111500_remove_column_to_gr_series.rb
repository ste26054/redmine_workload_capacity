class RemoveColumnToGrSeries < ActiveRecord::Migration
	def change
		remove_column :gr_series, :entry_id
		remove_column :gr_series, :entry_type
	end
end