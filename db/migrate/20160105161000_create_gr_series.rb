class CreateGrSeries < ActiveRecord::Migration
	def change
		create_table :gr_series do |t|
			t.references :type, polymorphic: true, index: true
			t.column :name, :string, :null => false
			t.column :chart_type, :integer, :null => false
			t.column :attribut, :integer, :null => false

			t.belongs_to :gr_graphs, index: true, :null => false
		end
	end
end