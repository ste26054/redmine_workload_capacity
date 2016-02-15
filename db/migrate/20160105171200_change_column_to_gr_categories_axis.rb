class ChangeColumnToGrCategoriesAxis < ActiveRecord::Migration
	def change
		change_column :gr_categories_axis, :type, :integer , :null => false
	end
end