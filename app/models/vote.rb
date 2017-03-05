class Vote < ActiveRecord::Base
  after_create :reload_ask_deal_vote_count, :create_vote_alarm
  after_update :reload_ask_deal_vote_count
  after_destroy :reload_ask_deal_vote_count

  def reload_ask_deal_vote_count
    ask = Ask.find(ask_id)
    ask_deal = ask_deal_id == ask.left_ask_deal_id ? ask.left_ask_deal : ask.right_ask_deal
    vote_count = Vote.where(ask_deal_id: ask_deal_id).count
    ask_deal.update(vote_count: vote_count)
  end

  def create_vote_alarm
    ask = Ask.find(ask_id)
    return if ask.be_completed
    total_vote_count = ask.left_ask_deal.vote_count + ask.right_ask_deal.vote_count
    return if total_vote_count.zero?
    return unless total_vote_count == 10 || total_vote_count == 25 || (total_vote_count % 50).zero?
    return unless User.find_by_id(ask.user_id).alarm_2 == true
    alarm = Alarm.where(user_id: ask.user_id,
                        ask_id: ask.id)
                 .where('alarm_type LIKE ?', 'vote_%').first
    if alarm
      alarm_count = alarm.alarm_type.delete('vote_').to_i
      if alarm_count < total_vote_count
        alarm.update(is_read: false,
                     alarm_type: "vote_#{total_vote_count}")
      end
    else
      Alarm.create(user_id: ask.user_id,
                   ask_id: ask.id,
                   alarm_type: "vote_#{total_vote_count}")
    end
  end
  handle_asynchronously :create_vote_alarm
end
