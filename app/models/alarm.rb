class Alarm < ActiveRecord::Base
  include PushSend

  belongs_to :ask
  belongs_to :comment
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :send_user, class_name: 'User', foreign_key: 'send_user_id'
  belongs_to :ask_owner_user, class_name: 'User', foreign_key: 'ask_owner_user_id'
  belongs_to :comment_owner_user, class_name: 'User', foreign_key: 'comment_owner_user_id'

  after_create :alarm_push_send
  after_update :alarm_push_send

  def alarm_push_send
    if Rails.env == 'development'
      if User.find(user_id).user_role == 'admin'
        registration_ids_ios = UserGcmKey.where(user_id: user_id)
                                         .where('device_id LIKE ?', 'ios%')
                                         .pluck(:gcm_key)
        registration_ids_aos = UserGcmKey.where(user_id: user_id)
                                         .where('device_id LIKE ?', 'android%')
                                         .pluck(:gcm_key)
      end
    else
      registration_ids_ios = UserGcmKey.where(user_id: user_id)
                                       .where('device_id LIKE ?', 'ios%')
                                       .pluck(:gcm_key)
      registration_ids_aos = UserGcmKey.where(user_id: user_id)
                                       .where('device_id LIKE ?', 'android%')
                                       .pluck(:gcm_key)
    end

    return if registration_ids_ios.blank? && registration_ids_aos.blank?

    # default setting
    alarms = Alarm.where(user_id: user_id).order(updated_at: :desc).limit(20)
    msg = '새로운 알림이 도착했습니다!'
    type = 'true'
    count = alarms.pluck(:is_read).count(false)
    id = ask_id.to_s
    link = "#{CONFIG['host']}/asks/#{ask_id}"
    js = "go_url('ask', #{ask_id})"
    # default setting

    if is_read == false
      if alarm_type =~ /^vote_/
        vote_count = alarm_type.delete('vote_').to_i
        msg = "회원님의 질문에 #{vote_count}명이 투표했습니다. 중간점검 해보세요!"
      elsif alarm_type =~ /^like_ask_/
        ask_like_count = alarm_type.delete('like_ask_').to_i
        send_user = User.find_by_id(send_user_id).string_id
        msg = "#{send_user}님이 회원님의 질문에 공감합니다."
        msg = "#{send_user}님 외 #{ask_like_count - 1}명이 회원님의 질문에 공감합니다." if ask_like_count > 1
      elsif alarm_type =~ /^like_comment_/
        comment_like_count = alarm_type.delete('like_comment_').to_i
        send_user = User.find_by_id(send_user_id).string_id
        msg = "#{send_user}님이 회원님의 의견을 좋아합니다."
        msg = "#{send_user}님 외 #{comment_like_count - 1}명이 회원님의 의견을 좋아합니다." if comment_like_count > 1
      elsif alarm_type =~ /^reply_comment_/
        reply_comment_count = alarm_type.delete('reply_comment_').to_i
        send_user = User.find_by_id(send_user_id).string_id
        msg = "#{send_user}님이 회원님의 의견에 댓글을 남겼습니다."
        msg = "#{send_user}님 외 #{reply_comment_count - 1}명이 회원님의 의견에 댓글을 남겼습니다." if reply_comment_count > 1
      elsif alarm_type =~ /^reply_sub_comment_/
        reply_sub_comment_count = alarm_type.delete('reply_sub_comment_').to_i
        send_user = User.find_by_id(send_user_id).string_id
        comment_owner_user = User.find_by_id(comment_owner_user_id).string_id
        msg = "#{send_user}님도 #{comment_owner_user}님의 의견에 댓글을 남겼습니다."
        msg = "#{send_user}님 외 #{reply_sub_comment_count - 1}명도 #{comment_owner_user}님의 의견에 댓글을 남겼습니다." if reply_sub_comment_count > 1
      elsif alarm_type =~ /^sub_comment_/
        sub_comment_count = alarm_type.delete('sub_comment_').to_i
        send_user = User.find_by_id(send_user_id).string_id
        ask_owner_user = User.find_by_id(ask_owner_user_id).string_id
        type = 'false'
        msg = "#{send_user}님도 #{ask_owner_user}님의 질문에 의견을 남겼습니다."
        msg = "#{send_user}님 외 #{sub_comment_count - 1}명도 #{ask_owner_user}님의 질문에 의견을 남겼습니다." if sub_comment_count > 1
      elsif alarm_type =~ /^comment_/
        comment_count = alarm_type.delete('comment_').to_i
        send_user = User.find_by_id(send_user_id).string_id
        msg = "#{send_user}님이 회원님의 질문에 의견을 남겼습니다."
        msg = "#{send_user}님 외 #{comment_count - 1}명이 회원님의 질문에 의견을 남겼습니다." if comment_count > 1
      end
    else
      type = 'false'
    end

    payload = {
      msg: msg,
      type: type,
      count: count,
      id: id,
      link: link,
      js: js
    }

    push_send_IOS(registration_ids_ios, payload) unless registration_ids_ios.blank?
    push_send_AOS(registration_ids_aos, payload) unless registration_ids_aos.blank?
  end
end
