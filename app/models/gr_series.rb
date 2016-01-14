class GrSeries < ActiveRecord::Base
  unloadable

  belongs_to :gr_graph
  has_many :gr_entries, :dependent => :destroy

  enum chart_type: { pie: 0, bar: 1, line: 2 } 

  validates :name, presence: true
  validates :chart_type, presence: true, inclusion: { in: GrSeries.chart_types.keys }
  validates :properties, presence: true
  validates :gr_graph_id, presence: true 

  serialize :properties

  attr_accessible :name, :chart_type, :properties, :gr_graph_id


private

end