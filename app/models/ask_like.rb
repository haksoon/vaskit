class AskLike < ActiveRecord::Base
  after_create :reload_ask_like_count, :create_ask_like_alarm
  after_update :reload_ask_like_count
  after_destroy :reload_ask_like_count

  def reload_ask_like_count
    ask = Ask.find_by_id(ask_id)
    like_count = AskLike.where(ask_id: ask_id)
                        .where.not(user_id: ask.user_id).count
    ask.update(like_count: like_count)
  end

  def create_ask_like_alarm
    ask = Ask.find_by_id(ask_id)

    return if user_id == ask.user_id
    return unless User.find(ask.user_id).alarm_1 == true
    like_count = AskLike.where(ask_id: ask_id)
                        .where.not(user_id: ask.user_id).count
    alarm = Alarm.where(user_id: ask.user_id,
                        ask_id: ask.id)
                 .where('alarm_type LIKE ?', 'like_ask_%').first
    if alarm
      alarm_count = alarm.alarm_type.delete('like_ask_').to_i
      if alarm_count < like_count
        alarm.update(is_read: false,
                     send_user_id: user_id,
                     alarm_type: "like_ask_#{like_count}")
      end
    else
      Alarm.create(user_id: ask.user_id,
                   send_user_id: user_id,
                   ask_id: ask.id,
                   alarm_type: "like_ask_#{like_count}")
    end
  end
  handle_asynchronously :create_ask_like_alarm
end
