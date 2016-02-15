class RenameColumnToGrCategories < ActiveRecord::Migration
	def change
		rename_column :gr_categories, :type, :gr_category_type
	end
end