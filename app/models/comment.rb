class Comment < ActiveRecord::Base
  belongs_to :user

  has_attached_file :image, :styles => { :normal => "300>x" },
                    :url  => "/assets/comments/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/comments/:id/:style/:basename.:extension",
                    :default_url => "/images/custom/card_image_preview.png"
  validates_attachment_size :image, :less_than => 20.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/pjpeg', 'image/png', 'image/jpg', 'image/gif', 'application/octet-stream']

  after_create :reload_ask_deal_comment_count, :create_comment_alarm
  after_update :reload_ask_deal_comment_count
  after_destroy :reload_ask_deal_comment_count

  def reload_ask_deal_comment_count
    ask = Ask.find(self.ask_id)
    if ask.left_ask_deal.id == self.ask_deal_id
      ask.left_ask_deal.update(comment_count: Comment.where(ask_deal_id: ask.left_ask_deal_id, is_deleted: false).count)
    elsif ask.right_ask_deal.id == self.ask_deal_id
      ask.right_ask_deal.update(comment_count: Comment.where(ask_deal_id: ask.right_ask_deal_id, is_deleted: false).count)
    end
  end

  def create_comment_alarm
    ask = Ask.find(self.ask_id)

    #본인의 질문에 대한 댓글 알림 (type:comment)
    if ask.user_id != self.user_id
    if User.find_by_id(ask.user_id).alarm_3 == true #알림 옵션 체크
      alarm = Alarm.where(user_id: ask.user_id, ask_id: ask.id).where("alarm_type like ?", "comment_%").first
      if alarm
        alarm.update(is_read: false, send_user_id: self.user_id, alarm_type: "comment_" + Comment.where("ask_id = ? AND user_id <> ?", ask.id, ask.user_id).count.to_s  )
      else
        Alarm.create(user_id: ask.user_id, send_user_id: self.user_id, ask_id: ask.id, alarm_type: "comment_" + Comment.where("ask_id = ? AND user_id <> ?", ask.id, ask.user_id).count.to_s )
      end
    end
    end

    if comment_id == nil

      #본인이 댓글 단 질문에 추가 댓글 알림 (type:sub_comment)
      #과거에 달았던 애가 있는지 체크
      sub_comment_user_ids = Comment.where("ask_id = ? AND id < ? AND is_deleted = ?",  ask.id, self.id, false).pluck(:user_id).uniq
      sub_comment_user_ids.each_with_index do |sub_comment_user_id|
        if sub_comment_user_id != ask.user_id && self.user_id != sub_comment_user_id
        if User.find_by_id(sub_comment_user_id).alarm_6 == true #알림 옵션 체크
          sub_comment = Comment.where(ask_id: ask.id, user_id: sub_comment_user_id).first
          user_count = Comment.where("ask_id = ? AND id > ? AND user_id <> ?",  ask.id, sub_comment.id, sub_comment.user_id ).count
          alarm = Alarm.where(user_id: sub_comment.user_id, ask_owner_user_id: ask.user_id, ask_id: ask.id).where("alarm_type like ?", "sub_comment_%").first
          if alarm
            alarm.update(is_read: false, send_user_id: self.user_id, alarm_type: "sub_comment_" + user_count.to_s )
          else
            Alarm.create(user_id: sub_comment.user_id, send_user_id: self.user_id, ask_owner_user_id: ask.user_id, ask_id: ask.id, alarm_type: "sub_comment_" + user_count.to_s )
          end
        end
        end
      end

    #대댓글 작성시 알람 생성
    elsif comment_id != nil
      original_comment = Comment.find(comment_id)

      #본인의 댓글에 대한 대댓글 알림 (type:reply_comment)
      if original_comment.user_id != self.user_id
      if User.find_by_id(original_comment.user_id).alarm_5 == true #알림 옵션 체크
        alarm = Alarm.where(user_id: original_comment.user_id, ask_id: ask.id).where("alarm_type like ?", "reply_comment_%").first
        if alarm
          alarm.update(is_read: false, send_user_id: self.user_id, alarm_type: "reply_comment_" + Comment.where("comment_id = ?", self.comment_id).count.to_s  )
        else
          Alarm.create(user_id: original_comment.user_id, send_user_id: self.user_id, ask_id: ask.id, alarm_type: "reply_comment_" + Comment.where("comment_id = ?", self.comment_id).count.to_s )
        end
      end
      end

      #본인이 대댓글 단 댓글에 대한 추가 대댓글 알림 (type:reply_sub_comment)
      reply_sub_comment_user_ids = Comment.where("comment_id = ? AND id < ? AND is_deleted = ?", original_comment.id, self.id, false).pluck(:user_id).uniq
      reply_sub_comment_user_ids.each_with_index do |reply_sub_comment_user_id|
        if self.user_id != reply_sub_comment_user_id
        if User.find_by_id(reply_sub_comment_user_id).alarm_6 == true #알림 옵션 체크
          reply_sub_comment = Comment.where(comment_id: original_comment.id, user_id: reply_sub_comment_user_id).first
          user_count = Comment.where("comment_id = ? AND id > ? AND user_id <> ?",  original_comment.id, reply_sub_comment.id, reply_sub_comment.user_id ).count
          alarm = Alarm.where(user_id: reply_sub_comment.user_id, ask_id: ask.id, comment_owner_user_id: original_comment.user_id, comment_id: original_comment.id).where("alarm_type like ?", "reply_sub_comment_%").first
          if alarm
            alarm.update(is_read: false, send_user_id: self.user_id, alarm_type: "reply_sub_comment_" + user_count.to_s )
          else
            Alarm.create(user_id: reply_sub_comment.user_id, send_user_id: self.user_id, ask_id: ask.id, comment_owner_user_id: original_comment.user_id, comment_id: original_comment.id, alarm_type: "reply_sub_comment_" + user_count.to_s )
          end
        end
        end
      end

    end
  end
  handle_asynchronously :create_comment_alarm

end
