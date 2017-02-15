class UserGcmKeysController < ApplicationController
  # POST /user_gcm_keys.json
  def create
    user_id = current_user ? current_user.id : nil
    gcm_key = params[:gcm_key]
    device_id = params[:device_id]
    app_ver = params[:app_ver]

    user_gcm_key = UserGcmKey.find_by(gcm_key: gcm_key)

    if user_gcm_key.nil?
      user_gcm_key = UserGcmKey.create(user_id: user_id,
                                       gcm_key: gcm_key,
                                       device_id: device_id,
                                       app_ver: app_ver)
    elsif user_gcm_key.user_id != user_id || user_gcm_key.gcm_key != gcm_key || user_gcm_key.device_id != device_id || user_gcm_key.app_ver != app_ver
      user_gcm_key.update(user_id: user_id,
                          gcm_key: gcm_key,
                          device_id: device_id,
                          app_ver: app_ver)
    end

    # 앱 뱃지 카운트 초기화
    registration_ids = []
    registration_ids << gcm_key
    if current_user
      alarms = Alarm.where(user_id: current_user.id)
                    .order(updated_at: :desc)
                    .limit(20)
      count = alarms.pluck(:is_read).count(false).to_s
    else
      count = '0'
    end

    payload = {
      type: 'false',
      count: count
    }

    push_send_AOS(registration_ids, payload) if device_id =~ /android/
    push_send_IOS(registration_ids, payload) if device_id =~ /ios/

    render json: { status: status }
  end
end
