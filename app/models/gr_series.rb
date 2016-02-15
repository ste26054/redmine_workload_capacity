class GrSeries < ActiveRecord::Base
  unloadable

  belongs_to :gr_graph
  has_many :gr_entries, :dependent => :destroy

  enum chart_type: { pie: 0, column: 1, line: 2, spline: 3, area: 4, bar: 5 } 

  validates :name, presence: true, allow_blank: false
  validates :chart_type, presence: true, inclusion: { in: GrSeries.chart_types.keys }
  validates :properties, presence: true
  validates :gr_graph_id, presence: true 

  serialize :properties

  attr_accessible :name, :chart_type, :properties, :gr_graph_id


private

end