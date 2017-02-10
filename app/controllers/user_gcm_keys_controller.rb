class UserGcmKeysController < ApplicationController

  # POST /user_gcm_keys.json
  def create
    gcm_key = params[:gcm_key]
    device_id = params[:device_id]
    app_ver = params[:app_ver]

    user_gcm_key = UserGcmKey.find_by(device_id: device_id)
    if current_user
      if user_gcm_key.nil?
        user_gcm_key = UserGcmKey.find_by(gcm_key: gcm_key)
        if user_gcm_key.nil?
          status = "log_in"
          user_gcm_key = UserGcmKey.create(user_id: current_user.id, gcm_key: gcm_key, device_id: device_id, app_ver: app_ver)
        else
          status = "device_changed"
          user_gcm_key.update(user_id: current_user.id, device_id: device_id, app_ver: app_ver)
        end
      else
        if user_gcm_key.gcm_key == gcm_key && user_gcm_key.app_ver == app_ver
          status = "token_existed"
        else
          status = "token_updated"
          user_gcm_key.update(user_id: current_user.id, gcm_key: gcm_key, app_ver: app_ver)
        end
      end
    else
      # 로그아웃한 경우 또는 앱을 삭제했다가 다시 설치한 경우 기존 정보 제거함 (단, 앱 삭제 시점은 캐치할 수 없음)
      UserGcmKey.where("gcm_key = ? OR device_id = ?", gcm_key, device_id).destroy_all
      status = "log_out"
    end

    # 앱 뱃지 카운트 초기화
    registration_ids = []
    registration_ids << gcm_key
    if status == "log_out"
      count = "0"
    else
      alarms = Alarm.where(user_id: current_user.id).order(updated_at: :desc).limit(20)
      count = alarms.pluck(:is_read).count(false).to_s
    end

    payload = {
      type: "false",
      count: count,
    }

    push_send_AOS(registration_ids, payload) if device_id.match(/android/)
    push_send_IOS(registration_ids, payload) if device_id.match(/ios/)

    render json: {status: status}
  end

end
