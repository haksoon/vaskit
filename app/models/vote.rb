class Vote < ActiveRecord::Base
  after_create :incr_ask_deal_vote_count
  
  def incr_ask_deal_vote_count
    ask = Ask.find_by_id(self.ask_id)
    if ask.left_ask_deal_id == self.ask_deal_id
      ask.left_ask_deal.update(:vote_count => Vote.where(:ask_deal_id => self.ask_deal_id).count )
    elsif ask.right_ask_deal_id == self.ask_deal_id
       ask.right_ask_deal.update(:vote_count => Vote.where(:ask_deal_id => self.ask_deal_id).count )
    end
    
    total_vote_count = (ask.left_ask_deal.vote_count + ask.right_ask_deal.vote_count)
    
    if total_vote_count == 10
      Alram.create(:user_id => ask.user_id, :ask_id => ask.id, :alram_type => "vote_10")
    elsif total_vote_count != 0 && total_vote_count%50 == 0
      alram = Alram.where(:user_id => ask.user_id, :ask_id => ask.id).where("alram_type like ?", "vote_%").first
      alram.update(:is_read => false, :alram_type => "vote_"+total_vote_count.to_s)
    end 
  end
  
end
