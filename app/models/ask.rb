class Ask < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :left_ask_deal, :class_name => 'AskDeal', :foreign_key => 'left_ask_deal_id'
  belongs_to :right_ask_deal, :class_name => 'AskDeal', :foreign_key => 'right_ask_deal_id'
  has_many :votes
  has_many :ask_likes
  has_many :hash_tags
  has_many :comments
  has_one :ask_complete

  include SlackNotifier

  ASK_PER = 5

  def detail_vote_count
    age_20 = Date.new(Time.now.year - 18, 1, 1)
    age_20_1_end = Date.new(Time.now.year - 22, 1, 1)
    age_20_2_end = Date.new(Time.now.year - 25, 1, 1)
    age_30 = Date.new(Time.now.year - 28, 1, 1)
    age_30_1_end = Date.new(Time.now.year - 32, 1, 1)
    age_30_2_end = Date.new(Time.now.year - 35, 1, 1)
    age_30_3_end = Date.new(Time.now.year - 38, 1, 1)

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
        :etc_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday IS NULL OR (users.birthday > ? OR users.birthday < ?)", age_20, age_30_3_end).where("votes.ask_deal_id = ?", self.left_ask_deal_id).count
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
        :etc_count => Vote.joins("JOIN users ON votes.user_id = users.id").where("users.birthday IS NULL OR (users.birthday > ? OR users.birthday < ?)", age_20, age_30_3_end).where("votes.ask_deal_id = ?", self.right_ask_deal_id).count
      }
    }
  end

  def generate_hash_tags
    HashTag.destroy_all(ask_id: self.id) # 업데이트의 경우 기존 해시태그를 모두 삭제한 후 재설정
    hash_tags = self.message.scan(/#[0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣_]*/)
    hash_tags.each do |hash_tag|
      hash_tag = hash_tag.tr("#","").tr(",","")
      HashTag.create(ask_id: self.id, user_id: self.user_id, keyword: hash_tag)
    end
  end

  def ask_notifier(type)
    if self.user.user_role == "user"
      noti_title = "[" + self.id.to_s + "번](" + CONFIG["host"] + "/asks/" + self.id.to_s + ")"
      noti_message = "- 작성자 : " + self.user.string_id.to_s + " (" + (self.user.gender == true ? '남성' : '여성').to_s + ", " + (Time.now.year - self.user.birthday.year + 1).to_s + "세)"
      if type == "new"
        noti_title += " / 새로운 질문이 작성되었습니다"
        noti_color = "#FF7200"
        noti_message += "\n- " + ((Time.now - self.user.created_at)/60/60/24).to_i.to_s + "일 전 가입자"
        noti_message += " / " + (Ask.where(user_id: self.user_id).count).to_s + "번째 작성한 질문"
      elsif type == "edit"
        noti_title += " / 사용자가 질문을 수정하였습니다"
        noti_color = "#666666"
        noti_message += "\n- " + ((Time.now - self.created_at)/60/60/24).to_i.to_s + "일 전 작성된 질문"
      elsif type == "complete"
        noti_title += " / 사용자가 질문을 종료하였습니다"
        noti_message += "\n- 투표 " + (self.left_ask_deal.vote_count + self.right_ask_deal.vote_count).to_s + "표"
        noti_message += " / 댓글 " + (self.left_ask_deal.comment_count + self.right_ask_deal.comment_count).to_s + "개"
        noti_message += " / 공감 " + self.like_count.to_s + "회"
        noti_color = "#333333"
      end
      noti_message += "\n- 내용\n" + self.message.to_s

      slack_notifier(noti_title, noti_message, noti_color)

      if type == "new" && Rails.env == "production"
        noti_title = "새로운 질문이 작성되었습니다! 댓글을 작성해주세요 :)"
        noti_title += "\n[링크로 이동](" + CONFIG["host"] + "/asks/" + self.id.to_s + ")"
        noti_message = self.message.to_s
        noti_color = "#FF7200"
        slack_notifier_alba(noti_title, noti_message, noti_color)
      end
    end
  end
  handle_asynchronously :ask_notifier

end
