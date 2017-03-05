class CommentLike < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment

  after_create :reload_comment_like_count, :create_comment_like_alarm
  after_update :reload_comment_like_count
  after_destroy :reload_comment_like_count

  def reload_comment_like_count
    comment = Comment.find_by_id(comment_id)
    like_count = CommentLike.where(comment_id: comment_id)
                            .where.not(user_id: comment.user_id).count
    comment.update(like_count: like_count)
  end

  def create_comment_like_alarm
    comment = Comment.find_by_id(comment_id)

    return if user_id == comment.user_id
    return unless User.find_by_id(comment.user_id).alarm_4 == true
    like_count = CommentLike.where(comment_id: comment_id)
                            .where.not(user_id: comment.user_id).count
    alarm = Alarm.where(user_id: comment.user_id,
                        comment_id: comment.id)
                 .where('alarm_type LIKE ?', 'like_comment_%').first
    if alarm
      alarm_count = alarm.alarm_type.delete('like_comment_').to_i
      if alarm_count < like_count
        alarm.update(is_read: false,
                     send_user_id: user_id,
                     alarm_type: "like_comment_#{like_count}")
      end
    else
      Alarm.create(user_id: comment.user_id,
                   send_user_id: user_id,
                   ask_id: comment.ask_id,
                   comment_id: comment.id,
                   alarm_type: "like_comment_#{like_count}")
    end
  end
  handle_asynchronously :create_comment_like_alarm
end
