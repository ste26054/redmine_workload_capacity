class CreateGrGraphs < ActiveRecord::Migration
	def change
		create_table :gr_graphs do |t|
			t.column :plugin_reference, :integer, default: 0, :null => false
			t.column :name, :string, :limit => 255, :null => false

			t.belongs_to :user, index: true, :null => false
			t.belongs_to :project, index: true, :null => false
			
		end
	end
end