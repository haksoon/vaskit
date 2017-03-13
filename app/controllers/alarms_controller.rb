class AlarmsController < ApplicationController
  # GET /alarms.json
  def index
    if current_user
      new_alarms = Alarm.where(user_id: current_user.id, is_read: false)
      unless new_alarms.blank?
        last_alarm = new_alarms.last
        new_alarms.update_all(is_read: true)
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
