class GrDatum < ActiveRecord::Base
  unloadable


  belongs_to :gr_graph

  validates :storage_data, presence: true
  validates :gr_graph_id, presence: true 

  serialize :storage_data
  
  attr_accessible :storage_data, :gr_graph_id

private

end