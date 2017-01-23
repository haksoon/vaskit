# coding : utf-8
class AlarmsController < ApplicationController

  # GET /alarms.json
  def index
    all_alarms = Alarm.where(user_id: current_user.id, is_read: false)
    unless all_alarms.blank?
      last_alarm = all_alarms.last
      all_alarms.update_all(is_read: true)
      # updated_at 바뀌지 않고 마지막 알람에 대해서만 푸쉬 보내는 callback이 트리거되도록 조정
      last_alarm.record_timestamps = false
      last_alarm.update(is_read: true)
      last_alarm.record_timestamps = true
    end

    render json: {status: "success"}
  end

end
