class Vote < ActiveRecord::Base
  after_create :reload_ask_deal_vote_count
  after_update :reload_ask_deal_vote_count
  after_destroy :reload_ask_deal_vote_count

  def reload_ask_deal_vote_count
    ask = Ask.find_by_id(self.ask_id)
    ask.left_ask_deal.update(vote_count: Vote.where(ask_deal_id: ask.left_ask_deal_id).count)
    ask.right_ask_deal.update(vote_count: Vote.where(ask_deal_id: ask.right_ask_deal_id).count)

    total_vote_count = (ask.left_ask_deal.vote_count + ask.right_ask_deal.vote_count)
    if total_vote_count != 0 && (total_vote_count == 10 || total_vote_count == 25 || total_vote_count % 50 == 0)
      create_vote_alarm(total_vote_count)
    end
  end

  def create_vote_alarm
    if User.find_by_id(ask.user_id).alarm_2 == true #알림 옵션 체크
      alarm = Alarm.where(user_id: ask.user_id, ask_id: ask.id).where("alarm_type LIKE ?", "vote_%").first
      if alarm
        alarm_count = alarm.alarm_type.gsub("vote_","").to_i
        if alarm_count < total_vote_count
          alarm.update(is_read: false, alarm_type: "vote_"+total_vote_count.to_s)
        end
      else
        Alarm.create(user_id: ask.user_id, ask_id: ask.id, alarm_type: "vote_"+total_vote_count.to_s)
      end
    end
  end
  handle_asynchronously :create_vote_alarm

end
