class GrCategory < ActiveRecord::Base
  unloadable

  belongs_to :gr_graph

  enum gr_category_type: { date: 0, other: 1 } 

  validates :gr_category_type, presence: true, inclusion: { in: GrCategory.gr_category_types.keys }
  validates :properties, presence: true
  validates :gr_graph_id, presence: true 

  validate :check_dates

  serialize :properties

  attr_accessible :gr_category_type, :properties, :gr_graph_id

private

def check_dates
	if self.properties[:start_date] && self.properties[:end_date]
		errors.add(:base, l(:error_dates)) if self.properties[:end_date] < self.properties[:start_date]
	end
end

end