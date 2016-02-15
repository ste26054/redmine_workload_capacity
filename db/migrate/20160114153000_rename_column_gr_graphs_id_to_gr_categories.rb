class RenameColumnGrGraphsIdToGrCategories < ActiveRecord::Migration
	def change
		rename_column :gr_categories, :gr_graphs_id, :gr_graph_id
	end
end