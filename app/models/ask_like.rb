class AskLike < ActiveRecord::Base
  default_scope { where(is_deleted: false) }

  belongs_to :user
  belongs_to :ask

  after_create :reload_ask_like_count, :create_ask_like_alarm
  after_update :reload_ask_like_count, :create_ask_like_alarm, if: :is_deleted

  def reload_ask_like_count
    ask = Ask.find(ask_id)
    like_count = AskLike.where(ask_id: ask_id)
                        .where.not(user_id: ask.user_id).count
    ask.update_columns(like_count: like_count)
  end

  # 본인의 질문에 대한 공감해요 알림 (alarm_1, type: like_ask)
  def create_ask_like_alarm
    ask = Ask.find(ask_id)

    return if user_id == ask.user_id || ask.be_completed
    return unless ask.user.alarm_1

    ask_likes = AskLike.where(ask_id: ask_id)
                       .where.not(user_id: ask.user_id)
    like_count = ask_likes.count

    alarm = Alarm.where(user_id: ask.user_id,
                        ask_id: ask.id)
                 .where('alarm_type LIKE ?', 'like_ask_%').first

    if alarm
      alarm_count = alarm.alarm_type.delete('like_ask_').to_i
      if like_count.zero?
        alarm.update_columns(user_id: nil,
                             alarm_type: "like_ask_#{like_count}")
      elsif like_count <= alarm_count
        last_like = ask_likes.last
        alarm.update_columns(send_user_id: last_like.user_id,
                             alarm_type: "like_ask_#{like_count}")
      else
        alarm.update(is_read: false,
                     send_user_id: user_id,
                     alarm_type: "like_ask_#{like_count}")
      end
    else
      return if like_count.zero?
      Alarm.create(user_id: ask.user_id,
                   send_user_id: user_id,
                   ask_id: ask.id,
                   alarm_type: "like_ask_#{like_count}")
    end
  end
  handle_asynchronously :create_ask_like_alarm
end
