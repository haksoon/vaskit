class Alarm < ActiveRecord::Base
  belongs_to :ask
  belongs_to :comment
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  belongs_to :send_user, class_name: 'User', foreign_key: 'send_user_id'
  belongs_to :ask_owner_user, class_name: 'User', foreign_key: 'ask_owner_user_id'
  belongs_to :comment_owner_user, class_name: 'User', foreign_key: 'comment_owner_user_id'

  include PushSend
  after_create :alarm_push_send
  after_update :alarm_push_send

  def alarm_push_send
    if Rails.env == "development"
      if User.find(self.user_id).user_role == "admin"
        registration_ids_ios = UserGcmKey.where(user_id: self.user_id).where("device_id LIKE ?", "ios%").pluck(:gcm_key)
        registration_ids_aos = UserGcmKey.where(user_id: self.user_id).where("device_id LIKE ?", "android%").pluck(:gcm_key)
      end
    else
      registration_ids_ios = UserGcmKey.where(user_id: self.user_id).where("device_id LIKE ?", "ios%").pluck(:gcm_key)
      registration_ids_aos = UserGcmKey.where(user_id: self.user_id).where("device_id LIKE ?", "android%").pluck(:gcm_key)
    end

    unless registration_ids_ios.blank? && registration_ids_aos.blank?
      # default setting
      alarms = Alarm.where(user_id: self.user_id).order(updated_at: :desc).limit(20)
      msg = "새로운 알림이 도착했습니다!"
      type = "true"
      count = alarms.pluck(:is_read).count(false)
      id = self.ask_id.to_s
      link = CONFIG["host"] + "/asks/" + self.ask_id.to_s
      js = "go_url('ask', " + self.ask_id.to_s + ")"
      # default setting

      if self.is_read == false
        if self.alarm_type.match("vote_")
          vote_count = self.alarm_type.gsub("vote_","").to_i
          msg = "회원님의 질문에 " + vote_count.to_s + "명이 투표했습니다. 중간점검 해보세요!"
        elsif self.alarm_type.match("like_ask_")
          ask_like_count = self.alarm_type.gsub("like_ask_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          if ask_like_count == 1
            msg = send_user + "님이 회원님의 질문에 공감합니다."
          else
            msg = send_user + "님 외 " + (ask_like_count - 1).to_s + "명이 회원님의 질문에 공감합니다."
          end
        elsif self.alarm_type.match("like_comment_")
          comment_like_count = self.alarm_type.gsub("like_comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          if comment_like_count == 1
            msg = send_user + "님이 회원님의 의견을 좋아합니다."
          else
            msg = send_user + "님 외 " + (comment_like_count - 1).to_s + "명이 회원님의 의견을 좋아합니다."
          end
        elsif self.alarm_type.match("reply_comment_")
          reply_comment_count = self.alarm_type.gsub("reply_comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          if reply_comment_count == 1
            msg = send_user + "님이 회원님의 의견에 댓글을 남겼습니다."
          else
            msg = send_user + "님 외 " + (reply_comment_count - 1).to_s + "명이 회원님의 의견에 댓글을 남겼습니다."
          end
        elsif self.alarm_type.match("reply_sub_comment_")
          reply_sub_comment_count = self.alarm_type.gsub("reply_sub_comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          comment_owner_user = User.find_by_id(self.comment_owner_user_id).string_id
          if reply_sub_comment_count == 1
            msg = send_user + "님도 " + comment_owner_user + "님의 의견에 댓글을 남겼습니다."
          else
            msg = send_user + "님 외 " + (reply_sub_comment_count - 1).to_s + "명도 " + comment_owner_user + "님의 의견에 댓글을 남겼습니다."
          end
        elsif self.alarm_type.match("sub_comment_")
          sub_comment_count = self.alarm_type.gsub("sub_comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          ask_owner_user = User.find_by_id(self.ask_owner_user_id).string_id
          type = "false"
          if sub_comment_count == 1
            msg = send_user + "님도 " + ask_owner_user + "님의 질문에 의견을 남겼습니다."
          else
            msg = send_user + "님 외 " + (sub_comment_count - 1).to_s + "명도 " + ask_owner_user + "님의 질문에 의견을 남겼습니다."
          end
        elsif self.alarm_type.match("comment_")
          comment_count = self.alarm_type.gsub("comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          if comment_count == 1
            msg = send_user + "님이 회원님의 질문에 의견을 남겼습니다."
          else
            msg = send_user + "님 외 " + (comment_count - 1).to_s + "명이 회원님의 질문에 의견을 남겼습니다."
          end
        end
      else
        type = "false"
      end
      push_send_IOS(registration_ids_ios, msg, type, count, id, link, js)
      push_send_AOS(registration_ids_aos, msg, type, count, id, link, js)
    end
  end
  handle_asynchronously :alarm_push_send

end
