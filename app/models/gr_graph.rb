class GrGraph < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :project

  has_one :gr_category, :dependent => :destroy
  has_many :gr_series, :dependent => :destroy

  enum plugin_reference: { doo: 0, allocation: 1, kpi: 2, forecast: 3} 
 
  validates :plugin_reference, presence: true, inclusion: { in: GrGraph.plugin_references.keys }
  validates :name, presence: true
  validates :user_id, presence: true
  validates :project_id, presence: true 

  attr_accessible :plugin_reference, :name, :user_id, :project_id

private

end
