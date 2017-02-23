module PushSend
  require 'fcm'
  FCM_API_KEY = "AAAATqbi_ZU:APA91bFC_wm0P1piz2p4PRX6R8nopu4SEUxY-Z11wb-TR9JmRSnPmOOAPTYtPZdcPXh-2Jy-GjPBWESCQn2ABeyNY9luva7FIavqEtgjinuXiTE2lzkY7DKT_yQ_1VUPgwGsHqH_K1uviqjVEUppk4lVqvM3mBeOCQ"

  # iOS 푸쉬 보내기
  def push_send_IOS(registration_ids, payload)
    fcm = FCM.new(PushSend::FCM_API_KEY)

    # options 의 모든 전달값은 String으로 전달할 것
    if payload[:type] == 'true'
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
        title: 'VASKIT',                  # 알림 타이틀
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

    puts ">>> TOKEN #{registration_ids.length}개 검증 결과 ..."
    puts ">>>> 존재하지 않는 TOKEN #{response[:not_registered_ids].length}개 제거 완료"
    puts ">>>>> 유효한 TOKEN #{registration_ids.length - response[:not_registered_ids].length}개"
  end
end
