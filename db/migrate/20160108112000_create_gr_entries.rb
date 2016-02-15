class CreateGrEntries < ActiveRecord::Migration
	def change
		create_table :gr_entries do |t|
			t.references :entry, polymorphic: true, index: true

			t.belongs_to :gr_series, index: true, :null => false
		end
	end
end