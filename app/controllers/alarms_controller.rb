class AlarmsController < ApplicationController
  # GET /alarms.json
  def index
    if current_user
      all_alarms = Alarm.where(user_id: current_user.id, is_read: false)
      unless all_alarms.blank?
        last_alarm = all_alarms.last
        all_alarms.update_all(is_read: true)
        last_alarm.record_timestamps = false
        last_alarm.update(is_read: true)
        last_alarm.record_timestamps = true
        status = 'success'
      end
    else
      status = 'not_authorized'
    end

    render json: { status: status }
  end
end
