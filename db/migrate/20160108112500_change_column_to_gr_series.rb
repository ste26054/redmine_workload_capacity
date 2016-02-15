class ChangeColumnToGrSeries < ActiveRecord::Migration
	def change
		change_column :gr_series, :attribut, :text , :null => false
		rename_column :gr_series, :attribut, :properties
	end
end