class Ask < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :left_ask_deal, :class_name => 'AskDeal', :foreign_key => 'left_ask_deal_id'
  belongs_to :right_ask_deal, :class_name => 'AskDeal', :foreign_key => 'right_ask_deal_id'
  has_many :comments
  has_one :rank_ask
  has_one :ask_complete
  
  ASK_PER = 5
  
  def detail_vote_count
    age_20 = Date.new(Time.now.year - 19, 1, 1)
    age_20_1_end = Date.new(Time.now.year - 23, 1, 1)
    age_20_2_end = Date.new(Time.now.year - 26, 1, 1)
    age_30 = Date.new(Time.now.year - 29, 1, 1)
    age_30_1_end = Date.new(Time.now.year - 33, 1, 1)
    age_30_2_end = Date.new(Time.now.year - 36, 1, 1)
    age_30_3_end = Date.new(Time.now.year - 39, 1, 1)
    
    detail_vote_count = {
      :left => {
        :male_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.gender = true").where("votes.ask_deal_id = ?", self.left_ask_deal_id).count,
        :female_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.gender = false").where("votes.ask_deal_id = ?", self.left_ask_deal_id).count,
        :age_20_1_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_20, age_20_1_end).where("votes.ask_deal_id = ?", self.left_ask_deal_id).count,
        :age_20_2_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_20_1_end, age_20_2_end).where("votes.ask_deal_id = ?", self.left_ask_deal_id).count,
        :age_20_3_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_20_2_end, age_30).where("votes.ask_deal_id = ?", self.left_ask_deal_id).count,
        :age_30_1_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_30, age_30_1_end).where("votes.ask_deal_id = ?", self.left_ask_deal_id).count,
        :age_30_2_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_30_1_end, age_30_2_end).where("votes.ask_deal_id = ?", self.left_ask_deal_id).count,
        :age_30_3_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_30_2_end, age_30_3_end).where("votes.ask_deal_id = ?", self.left_ask_deal_id).count,
        :etc_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday IS NOT NULL AND (users.birthday > ? OR users.birthday < ?)", age_20, age_30_3_end).where("votes.ask_deal_id = ?", self.left_ask_deal_id).count
      },
      :right => {
        :male_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.gender = true").where("votes.ask_deal_id = ?", self.right_ask_deal_id).count,
        :female_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.gender = false").where("votes.ask_deal_id = ?", self.right_ask_deal_id).count,
        :age_20_1_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_20, age_20_1_end).where("votes.ask_deal_id = ?", self.right_ask_deal_id).count,
        :age_20_2_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_20_1_end, age_20_2_end).where("votes.ask_deal_id = ?", self.right_ask_deal_id).count,
        :age_20_3_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_20_2_end, age_30).where("votes.ask_deal_id = ?", self.right_ask_deal_id).count,
        :age_30_1_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_30, age_30_1_end).where("votes.ask_deal_id = ?", self.right_ask_deal_id).count,
        :age_30_2_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_30_1_end, age_30_2_end).where("votes.ask_deal_id = ?", self.right_ask_deal_id).count,
        :age_30_3_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday < ? AND users.birthday > ?", age_30_2_end, age_30_3_end).where("votes.ask_deal_id = ?", self.right_ask_deal_id).count,
        :etc_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday IS NOT NULL AND (users.birthday > ? OR users.birthday < ?)", age_20, age_30_3_end).where("votes.ask_deal_id = ?", self.right_ask_deal_id).count
      }
    }
    
  end
  
end
