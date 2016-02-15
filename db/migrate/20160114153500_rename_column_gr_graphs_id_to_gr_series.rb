class RenameColumnGrGraphsIdToGrSeries < ActiveRecord::Migration
	def change
		rename_column :gr_series, :gr_graphs_id, :gr_graph_id
	end
end