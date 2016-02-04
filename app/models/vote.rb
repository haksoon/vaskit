class Vote < ActiveRecord::Base
  after_create :incr_ask_deal_vote_count
  
  def incr_ask_deal_vote_count
    ask = Ask.find_by_id(self.ask_id)
    if ask.left_ask_deal_id == self.ask_deal_id
      ask.left_ask_deal.update(:vote_count => Vote.where(:ask_deal_id => self.ask_deal_id).count )
    elsif ask.right_ask_deal_id == self.ask_deal_id
       ask.right_ask_deal.update(:vote_count => Vote.where(:ask_deal_id => self.ask_deal_id).count )
    end
  end
  
end
