class GrCategory < ActiveRecord::Base
  unloadable

  belongs_to :gr_graphs

  enum gr_category_type: { date: 0, other: 1 } 

  validates :gr_category_type, presence: true, inclusion: { in: GrCategory.gr_category_types.keys }
  validates :properties, presence: true
  validates :gr_graphs_id, presence: true 

  serialize :properties

  attr_accessible :gr_category_type, :properties, :gr_graphs_id

private

end