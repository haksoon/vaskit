class CommentLike < ActiveRecord::Base
  default_scope { where(is_deleted: false) }

  belongs_to :user
  belongs_to :comment

  after_create :reload_comment_like_count, :create_comment_like_alarm
  after_update :reload_comment_like_count, :create_comment_like_alarm, if: :is_deleted

  def reload_comment_like_count
    like_count = CommentLike.where(comment_id: comment_id)
                            .where.not(user_id: comment.user_id).count
    comment.update_columns(like_count: like_count)
  end

  # 본인의 댓글에 대한 좋아요 알림 (alarm_4, type: like_comment)
  def create_comment_like_alarm
    return if user_id == comment.user_id
    return unless comment.user.alarm_4

    comment_likes = CommentLike.where(comment_id: comment_id)
                               .where.not(user_id: comment.user_id)
    like_count = comment_likes.count

    alarm = Alarm.where(user_id: comment.user_id,
                        original_comment_id: comment.id)
                 .where('alarm_type LIKE ?', 'like_comment_%').first

    if alarm
      alarm_count = alarm.alarm_type.delete('like_comment_').to_i
      if like_count.zero?
        alarm.update_columns(user_id: nil,
                             alarm_type: "like_comment_#{like_count}")
      elsif like_count <= alarm_count
        last_like = comment_likes.last
        alarm.update_columns(send_user_id: last_like.user_id,
                             alarm_type: "like_comment_#{like_count}")
      else
        alarm.update(is_read: false,
                     send_user_id: user_id,
                     alarm_type: "like_comment_#{like_count}")
      end
    else
      return if like_count.zero?
      Alarm.create(user_id: comment.user_id,
                   send_user_id: user_id,
                   ask_id: comment.ask_id,
                   original_comment_id: comment.id,
                   alarm_type: "like_comment_#{like_count}")
    end
  end
  handle_asynchronously :create_comment_like_alarm
end
