class CreateGrData < ActiveRecord::Migration
	def change
		create_table :gr_data do |t|
			t.column :data, :text, :null => false
			t.column :created_at, :datetime

			t.belongs_to :gr_graph, index: true, :null => false
		end
	end
end