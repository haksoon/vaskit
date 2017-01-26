class LogInquiry < ActiveRecord::Base
  include SlackNotifier
  after_create :inquiry_submit_notifier

  def inquiry_submit_notifier
    inquiry_user = User.find(self.user_id)
    inquiry_user_id = inquiry_user == nil ? "비회원" : inquiry_user.string_id

    noti_title = "문의가 접수되었습니다"
    noti_message = "- 내용\n" + self.message.to_s + "\n- 연락처: " + self.contact.to_s + " (" + inquiry_user_id.to_s + ")"
    noti_color = "#999999"
    slack_notifier(noti_title, noti_message, noti_color)
  end
  handle_asynchronously :inquiry_submit_notifier

end
