module PushSend
  require 'fcm'
  FCM_API_KEY = "AAAATqbi_ZU:APA91bFC_wm0P1piz2p4PRX6R8nopu4SEUxY-Z11wb-TR9JmRSnPmOOAPTYtPZdcPXh-2Jy-GjPBWESCQn2ABeyNY9luva7FIavqEtgjinuXiTE2lzkY7DKT_yQ_1VUPgwGsHqH_K1uviqjVEUppk4lVqvM3mBeOCQ"

  # iOS 푸쉬 보내기
  def push_send_IOS(registration_ids, msg, type, count, id, link, js)
    fcm = FCM.new(PushSend::FCM_API_KEY)

    if type == "true"
      options = {                 # options 의 모든 전달값은 String으로 전달할 것
        notification: {
          body: msg,              # 알림 메시지
          sound: type,            # 푸시 진동 울림
          badge: count            # 뱃지 카운트
        },
        data: {
          js: js                  # 알림항목과 연결할 JavaScript
        }
      }
    else
      options = {                 # options 의 모든 전달값은 String으로 전달할 것
        notification: {
          badge: count            # 뱃지 카운트
        }
      }
    end

    response = fcm.send(registration_ids, options)
    logger.debug response
  end

  # AOS 푸쉬 보내기
  def push_send_AOS(registration_ids, msg, type, count, id, link, js)
    fcm = FCM.new(PushSend::FCM_API_KEY)
    options = {                 # options 의 모든 전달값은 String으로 전달할 것
      data: {
        title: "VASKIT",        # 알림 타이틀
        msg: msg,               # 알림 메시지
        type: type,             # 푸시 진동 여부 true/false
        count: count,           # 뱃지 카운트
        id: id,                 # (AOS ONLY) 동일한 항목에 대한 푸시의 경우 알림목록을 업데이트하기 위한 구분값
        url: link,              # 알림항목과 연결할 URL
        js: js                  # 알림항목과 연결할 JavaScript
      }
    }
    response = fcm.send(registration_ids, options)
    logger.debug response
  end

end
