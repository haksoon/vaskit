class CommentLike < ActiveRecord::Base
  after_create :reload_comment_like_count
  after_update :reload_comment_like_count
  after_destroy :reload_comment_like_count

  def reload_comment_like_count
    comment = Comment.find_by_id(self.comment_id)
    comment.update(like_count: CommentLike.where(comment_id: self.comment_id).count)

    comment_like_count = CommentLike.where(comment_id: self.comment_id).where.not(user_id: comment.user_id).count

    if comment.user_id != self.user_id
      if User.find_by_id(comment.user_id).alarm_4 == true #알림 옵션 체크
        alarm = Alarm.where(user_id: comment.user_id, comment_id: comment.id).where("alarm_type like ?", "like_comment_%").first
        if alarm
          alarm_count = alarm.alarm_type.gsub("like_comment_","").to_i
          if alarm_count < comment_like_count
            alarm.update(is_read: false, send_user_id: self.user_id, alarm_type: "like_comment_"+comment_like_count.to_s)
          end
        else
          Alarm.create(user_id: comment.user_id, send_user_id: self.user_id, ask_id: comment.ask_id, comment_id: comment.id, alarm_type: "like_comment_"+comment_like_count.to_s)
        end
      end
    end
  end

end
