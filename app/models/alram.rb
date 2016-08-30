class Alram < ActiveRecord::Base
  include PushSend
  after_create :alram_push_send
  after_update :alram_push_send

  def alram_push_send
    if self.is_read == false
      registration_ids = UserGcmKey.where(:user_id => self.user_id).pluck(:gcm_key)
      unless registration_ids.blank?
        id = self.ask_id.to_s
        msg = "새로운 알림이 있어요. 확인해 보세요!"
        if self.alram_type.match("vote_")
          vote_count = self.alram_type.gsub("vote_","").to_i
          msg = "회원님의 질문에 " + vote_count.to_s + "명이 투표했습니다. 중간점검 해보세요!"
        elsif self.alram_type.match("like_ask_")
          ask_like_count = self.alram_type.gsub("like_ask_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          if ask_like_count == 1
            msg = send_user + "님이 회원님의 질문에 공감합니다."
          else
            msg = send_user + "님 외 " + (ask_like_count - 1).to_s + "명이 회원님의 질문에 공감합니다."
          end
        elsif self.alram_type.match("like_comment_")
          comment_like_count = self.alram_type.gsub("like_comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          if comment_like_count == 1
            msg = send_user + "님이 회원님의 의견을 좋아합니다."
          else
            msg = send_user + "님 외 " + (comment_like_count - 1).to_s + "명이 회원님의 의견을 좋아합니다."
          end
        elsif self.alram_type.match("reply_comment_")
          reply_comment_count = self.alram_type.gsub("reply_comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          if reply_comment_count == 1
            msg = send_user + "님이 회원님의 의견에 댓글을 남겼습니다."
          else
            msg = send_user + "님 외 " + (reply_comment_count - 1).to_s + "명이 회원님의 의견에 댓글을 남겼습니다."
          end
        elsif self.alram_type.match("reply_sub_comment_") #테스트
          reply_sub_comment_count = self.alram_type.gsub("reply_sub_comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          comment_owner_user = User.find_by_id(self.comment_owner_user_id).string_id
          if reply_sub_comment_count == 1
            msg = send_user + "님도 " + comment_owner_user + "님의 의견에 댓글을 남겼습니다."
          else
            msg = send_user + "님 외 " + (reply_sub_comment_count - 1).to_s + "명도 " + comment_owner_user + "님의 의견에 댓글을 남겼습니다."
          end
        elsif self.alram_type.match("sub_comment_")
          sub_comment_count = self.alram_type.gsub("sub_comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          ask_owner_user = User.find_by_id(self.ask_owner_user_id).string_id
          if sub_comment_count == 1
            msg = send_user + "님도 " + ask_owner_user + "님의 질문에 의견을 남겼습니다."
          else
            msg = send_user + "님 외 " + (sub_comment_count - 1).to_s + "명도 " + ask_owner_user + "님의 질문에 의견을 남겼습니다."
          end
        elsif self.alram_type.match("comment_")
          comment_count = self.alram_type.gsub("comment_","").to_i
          send_user = User.find_by_id(self.send_user_id).string_id
          if comment_count == 1
            msg = send_user + "님이 회원님의 질문에 의견을 남겼습니다."
          else
            msg = send_user + "님 외 " + (comment_count - 1).to_s + "명이 회원님의 질문에 의견을 남겼습니다."
          end
        end

        link = "http://vaskit.kr/asks/" + self.ask_id.to_s

        push_send(registration_ids, id, msg, link)
      end
    end
  end

end
