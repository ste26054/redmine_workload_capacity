class RenameGrCategories < ActiveRecord::Migration
	def change
		rename_table :gr_categories_axis, :gr_categories
	end
end