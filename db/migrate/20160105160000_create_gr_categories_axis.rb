class CreateGrCategoriesAxis < ActiveRecord::Migration
	def change
		create_table :gr_categories_axis do |t|
			t.column :type, :date, :null => false
			t.column :properties, :text, :null => false

			t.belongs_to :gr_graphs, index: true, :null => false
		end
	end
end