class AskLike < ActiveRecord::Base
  after_create :reload_ask_like_count
  after_update :reload_ask_like_count
  after_destroy :reload_ask_like_count

  def reload_ask_like_count
    ask = Ask.find_by_id(self.ask_id)
    ask.update(like_count: AskLike.where(ask_id: self.ask_id).count)

    ask_like_count = AskLike.where(ask_id: self.ask_id).where.not(user_id: ask.user_id).count

    if ask.user_id != self.user_id
      if User.find_by_id(ask.user_id).alarm_1 == true #알림 옵션 체크
        alarm = Alarm.where(user_id: ask.user_id, ask_id: ask.id).where("alarm_type like ?", "like_ask_%").first
        if alarm
          alarm_count = alarm.alarm_type.gsub("like_ask_","").to_i
          if alarm_count < ask_like_count
            alarm.update(is_read: false, send_user_id: self.user_id, alarm_type: "like_ask_"+ask_like_count.to_s)
          end
        else
          Alarm.create(user_id: ask.user_id, send_user_id: self.user_id, ask_id: ask.id, alarm_type: "like_ask_"+ask_like_count.to_s)
        end
      end
    end
  end

end
