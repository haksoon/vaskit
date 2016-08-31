module PushSend
  require 'gcm'

  # 기본 푸쉬 보내기 구조
  def push_send(registration_ids, id, msg, link)
    gcm = GCM.new("AIzaSyCjTh7XSgn2fDq_J8RMEeIpyii87DgTTE4")
    registration_ids = registration_ids
    options = {data: {title: "VASKIT", id: id, msg: msg, link: link}}
    response = gcm.send_notification(registration_ids, options)
    logger.debug response
  end

end
