module PushSend
  require 'fcm'
  FCM_API_KEY = "AAAATqbi_ZU:APA91bFC_wm0P1piz2p4PRX6R8nopu4SEUxY-Z11wb-TR9JmRSnPmOOAPTYtPZdcPXh-2Jy-GjPBWESCQn2ABeyNY9luva7FIavqEtgjinuXiTE2lzkY7DKT_yQ_1VUPgwGsHqH_K1uviqjVEUppk4lVqvM3mBeOCQ"

  def push_send_to_all(push_type, payload)
    if Rails.env == "development"
      admin_user = User.where(user_role: "admin").pluck(:id)
      registration_ids_ios = UserGcmKey.where(user_id: admin_user).where("device_id LIKE ?", "ios%").pluck(:gcm_key)
      registration_ids_aos = UserGcmKey.where(user_id: admin_user).where("device_id LIKE ?", "android%").pluck(:gcm_key)
    else
      registration_ids_ios = UserGcmKey.where("device_id LIKE ?", "ios%").pluck(:gcm_key)
      registration_ids_aos = UserGcmKey.where("device_id LIKE ?", "android%").pluck(:gcm_key)
    end

    response_ios = push_send_IOS(registration_ids_ios, payload) unless registration_ids_ios.blank?
    response_aos = push_send_AOS(registration_ids_aos, payload) unless registration_ids_aos.blank?

    body_ios = JSON.parse(response_ios[:body])
    body_aos = JSON.parse(response_aos[:body])

    LogPushAdmin.create(
        push_type: push_type,
        total_count: registration_ids_ios.length.to_i + registration_ids_aos.length.to_i,
        ios_count: registration_ids_ios.length.to_i,
        aos_count: registration_ids_aos.length.to_i,
        success_count: body_ios["success"].to_i + body_aos["success"].to_i,
        failure_count: body_ios["failure"].to_i + body_aos["failure"].to_i,
        message: payload[:msg]
    )
  end

  # iOS 푸쉬 보내기
  def push_send_IOS(registration_ids, payload)
    fcm = FCM.new(PushSend::FCM_API_KEY)

    # options 의 모든 전달값은 String으로 전달할 것
    if payload[:type] == "true"
      options = {
        notification: {
          body: payload[:msg],              # 알림 메시지
          sound: payload[:type],            # 푸시 진동 울림
          badge: payload[:count]            # 뱃지 카운트
        },
        data: {
          js: payload[:js]                  # 알림항목과 연결할 JavaScript
        }
      }
    else
      options = {
        notification: {
          badge: payload[:count]            # 뱃지 카운트
        }
      }
    end

    response = fcm.send(registration_ids, options)
    logger.debug response
    return response
  end

  # AOS 푸쉬 보내기
  def push_send_AOS(registration_ids, payload)
    fcm = FCM.new(PushSend::FCM_API_KEY)

    # options 의 모든 전달값은 String으로 전달할 것
    options = {
      data: {
        title: "VASKIT",                  # 알림 타이틀
        msg: payload[:msg],               # 알림 메시지
        type: payload[:type],             # 푸시 진동 여부 true/false
        count: payload[:count],           # 뱃지 카운트
        id: payload[:id],                 # (AOS ONLY) 동일한 항목에 대한 푸시의 경우 알림목록을 업데이트하기 위한 구분값
        url: payload[:link],              # 알림항목과 연결할 URL
        js: payload[:js]                  # 알림항목과 연결할 JavaScript
      }
    }

    response = fcm.send(registration_ids, options)
    logger.debug response
    return response
  end

  def self.token_check
    fcm = FCM.new(PushSend::FCM_API_KEY)

    registration_ids = UserGcmKey.all.pluck(:gcm_key)
    response = fcm.send(registration_ids)
    UserGcmKey.where(gcm_key: response[:not_registered_ids]).destroy_all unless response[:not_registered_ids].blank?

    return "TOKEN " + registration_ids.length.to_s + "개 검증 결과 존재하지 않는 TOKEN " + response[:not_registered_ids].length.to_s + "개 제거 완료"
  end

end
