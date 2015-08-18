class AddCriteriaToOvertimes < ActiveRecord::Migration
	def change
		add_column :wl_user_overtimes, :include_sat, :boolean, default: false
		add_column :wl_user_overtimes, :include_sun, :boolean, default: false
		add_column :wl_user_overtimes, :include_bank_holidays, :boolean, default: false
	end
end