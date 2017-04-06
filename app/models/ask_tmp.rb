class AskTmp < ActiveRecord::Base
  belongs_to :user
  belongs_to :left_ask_deal, class_name: 'AskDealTmp', foreign_key: 'left_ask_deal_id', dependent: :destroy
  belongs_to :right_ask_deal, class_name: 'AskDealTmp', foreign_key: 'right_ask_deal_id', dependent: :destroy
end
