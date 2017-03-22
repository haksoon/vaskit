class Vote < ActiveRecord::Base
  default_scope { where(is_deleted: false) }

  belongs_to :user
  belongs_to :ask
  belongs_to :ask_deal

  after_create :reload_ask_deal_vote_count, :create_vote_alarm
  after_update :reload_ask_deal_vote_count
  after_update :create_vote_alarm, if: :is_deleted

  def reload_ask_deal_vote_count
    ask = Ask.find(ask_id)
    left_vote_count = Vote.where(ask_deal_id: ask.left_ask_deal_id).count
    right_vote_count = Vote.where(ask_deal_id: ask.right_ask_deal_id).count
    ask.left_ask_deal.update_columns(vote_count: left_vote_count)
    ask.right_ask_deal.update_columns(vote_count: right_vote_count)
  end

  # 본인의 질문에 대한 투표 알림 (alarm_2, type: vote)
  def create_vote_alarm
    ask = Ask.find(ask_id)

    return if ask.be_completed || user_id == ask.user_id
    return unless ask.user.alarm_2

    left_vote_count = Vote.where(ask_deal_id: ask.left_ask_deal_id).count
    right_vote_count = Vote.where(ask_deal_id: ask.right_ask_deal).count
    total_vote_count = left_vote_count + right_vote_count
    return unless total_vote_count == 10 || total_vote_count == 25 || (total_vote_count % 50).zero?

    alarm = Alarm.where(user_id: ask.user_id,
                        ask_id: ask.id)
                 .where('alarm_type LIKE ?', 'vote_%').first
    if alarm
      alarm_count = alarm.alarm_type.delete('vote_').to_i
      if total_vote_count.zero?
        alarm.update_columns(user_id: nil,
                             alarm_type: "vote_#{total_vote_count}")
      elsif total_vote_count <= alarm_count
        alarm.update_columns(alarm_type: "vote_#{total_vote_count}")
      else
        alarm.update(is_read: false,
                     alarm_type: "vote_#{total_vote_count}")
      end
    else
      return if total_vote_count.zero?
      Alarm.create(user_id: ask.user_id,
                   ask_id: ask.id,
                   alarm_type: "vote_#{total_vote_count}")
    end
  end
  handle_asynchronously :create_vote_alarm
end
