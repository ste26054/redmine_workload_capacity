class WlCustomProjectWindow < ActiveRecord::Base
	unloadable
	
	belongs_to :wl_project_window
	belongs_to :user

	attr_accessible :start_date, :end_date, :wl_project_windows_id, :user_id

	validates :start_date, date: true, presence: true
  	validates :end_date, date: true, presence: true
  	validates :wl_project_windows_id, presence: true
  	validates :user_id, presence: true

private


end