module PushSend
  require 'gcm'

  # 기본 푸쉬 보내기 구조
  def push_send(registration_ids, type, count, msg, id, link)
    gcm = GCM.new("AIzaSyCjTh7XSgn2fDq_J8RMEeIpyii87DgTTE4")
    options = {data: {    # options 의 모든 전달값은 String으로 전달할 것
      title: "VASKIT",    # 알림 타이틀
      msg: msg,           # 알림 메시지
      type: type,         # 푸시 진동 여부 true/false
      count: count,       # 뱃지 카운트
      id: id,             # 동일한 항목에 대한 푸시의 경우 알림목록을 업데이트하기 위한 구분값
      link: link          # 알림항목과 연결할 주소
    }}
    response = gcm.send_notification(registration_ids, options)
    logger.debug response
  end

end
