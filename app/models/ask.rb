class Ask < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :left_ask_deal, :class_name => 'AskDeal', :foreign_key => 'left_ask_deal_id'
  belongs_to :right_ask_deal, :class_name => 'AskDeal', :foreign_key => 'right_ask_deal_id'
  has_many :comments
  has_one :ask_complete
end
