class GrGraph < ActiveRecord::Base
  unloadable

  belongs_to :user
  belongs_to :project

  has_one :gr_category, :dependent => :destroy
  has_many :gr_series, :dependent => :destroy
  has_many :gr_datum, :dependent => :destroy

  enum plugin_reference: { no_ref: 0, allocation: 1, kpi: 2, forecast: 3} 

 # validates_presence_of :name
  before_destroy :destroy_user_preferences

  validates :plugin_reference, presence: true, inclusion: { in: GrGraph.plugin_references.keys }
  validates :name, presence: true, allow_blank: false
  validates :user_id, presence: true
  validates :project_id, presence: true 

  attr_accessible :plugin_reference, :name, :user_id, :project_id

private

  def destroy_user_preferences
    block_name = "gr#{id}_block".underscore
    userpref_list = UserPreference.select{|u| u.others[:graph_alloc]}
    userpref_list.each do |up|
      upref = up.others[:graph_alloc]
      %w(top left right).each{|k| (upref[k] ||=[] ).delete block_name}
      user = up.user
      user.pref[:graph_alloc] = upref
      user.pref.save
    end
  end

end
