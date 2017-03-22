class Alarm < ActiveRecord::Base
  include PushSend

  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :send_user, class_name: 'User', foreign_key: 'send_user_id'
  belongs_to :ask_owner_user, class_name: 'User', foreign_key: 'ask_owner_user_id'
  belongs_to :comment_owner_user, class_name: 'User', foreign_key: 'comment_owner_user_id'
  belongs_to :ask
  belongs_to :comment
  belongs_to :original_comment, class_name: 'Comment', foreign_key: 'original_comment_id'

  after_create :alarm_push_send
  after_update :alarm_push_send

  def alarm_push_send
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
        return if vote_count.zero?
        msg = "회원님의 질문에 #{vote_count}명이 투표했습니다. 중간점검 해보세요!"
      elsif alarm_type =~ /^like_ask_/
        ask_like_count = alarm_type.delete('like_ask_').to_i
        return if ask_like_count.zero?
        msg = "회원님의 질문에 #{send_user.string_id}님"
        msg += " 외 #{ask_like_count - 1}명" if ask_like_count > 1
        msg += '이 공감합니다'
      elsif alarm_type =~ /^comment_/
        comment_count = alarm_type.delete('comment_').to_i
        return if comment_count.zero?
        msg = "회원님의 질문에 #{send_user.string_id}님"
        msg += " 외 #{comment_count - 1}명" if comment_count > 1
        msg += '이 의견을 남겼습니다:'
        msg += " \"#{comment.content.gsub(/\n/, ' ').truncate(25)}\""
      elsif alarm_type =~ /^like_comment_/
        comment_like_count = alarm_type.delete('like_comment_').to_i
        return if comment_like_count.zero?
        msg = "회원님의 의견을 #{send_user.string_id}님"
        msg += " 외 #{comment_like_count - 1}명" if comment_like_count > 1
        msg += '이 좋아합니다:'
        msg += " \"#{original_comment.content.gsub(/\n/, ' ').truncate(25)}\""
      elsif alarm_type =~ /^reply_comment_/
        reply_comment_count = alarm_type.delete('reply_comment_').to_i
        return if reply_comment_count.zero?
        msg = "회원님의 의견에 #{send_user.string_id}님"
        msg += " 외 #{reply_comment_count - 1}명" if reply_comment_count > 1
        msg += '이 댓글을 남겼습니다:'
        msg += " \"#{comment.content.gsub(/\n/, ' ').truncate(25)}\""
      elsif alarm_type =~ /^sub_comment_/
        sub_comment_count = alarm_type.delete('sub_comment_').to_i
        return if sub_comment_count.zero?
        type = 'false'
        msg = "회원님이 의견을 남긴 #{ask_owner_user.string_id}님의 질문에 #{send_user.string_id}님"
        msg += " 외 #{sub_comment_count - 1}명" if sub_comment_count > 1
        msg += '도 의견을 남겼습니다:'
        msg += " \"#{comment.content.gsub(/\n/, ' ').truncate(25)}\""
      elsif alarm_type =~ /^reply_sub_comment_/
        reply_sub_comment_count = alarm_type.delete('reply_sub_comment_').to_i
        return if reply_sub_comment_count.zero?
        msg = "회원님이 댓글을 남긴 #{comment_owner_user.string_id}님의 의견에 #{send_user.string_id}님"
        msg += " 외 #{reply_sub_comment_count - 1}명" if reply_sub_comment_count > 1
        msg += '도 댓글을 남겼습니다:'
        msg += " \"#{comment.content.gsub(/\n/, ' ').truncate(25)}\""
      elsif alarm_type =~ /^liked_ask_comment_/
        liked_ask_comment_count = alarm_type.delete('liked_ask_comment_').to_i
        return if liked_ask_comment_count.zero?
        msg = "회원님이 공감한 #{ask_owner_user.string_id}님의 질문에 #{send_user.string_id}님"
        msg += " 외 #{liked_ask_comment_count - 1}명" if liked_ask_comment_count > 1
        msg += '이 댓글을 남겼습니다:'
        msg += " \"#{comment.content.gsub(/\n/, ' ').truncate(25)}\""
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

    push_send_IOS(registration_ids_ios, payload) unless registration_ids_ios.blank?
    push_send_AOS(registration_ids_aos, payload) unless registration_ids_aos.blank?
  end
end
