class LogReport < ActiveRecord::Base
  include SlackNotifier
  after_create :report_submit_notifier

  def report_submit_notifier
    if self.target == "ask"
      target = Ask.find(self.target_id)
      target_content = "[질문]\n" + target.message
      target_url = CONFIG["host"] + "/asks/" + target.id.to_s
    elsif self.target == "comment"
      target = Comment.find(self.target_id)
      target_content = "[댓글]\n" + target.content
      target_url = CONFIG["host"] + "/asks/" + target.ask_id.to_s
    end

    if self.report_type == "1"
      report_message = "구매결정과는 무관한 내용이군요"
    elsif self.report_type == "2"
      report_message = "광고성, 홍보성이 짙은 내용이군요"
    elsif self.report_type == "3"
      report_message = "비윤리적인 내용은 보고싶지 않아요"
    elsif self.report_type == "4"
      report_message = self.message
    end
    report_user = User.find(self.user_id)
    report_user_id = report_user == nil ? "비회원" : report_user.string_id

    noti_title = "신고가 접수되었습니다"
    noti_title += "\n" + target_url.to_s
    noti_message = "- 신고자 : " + report_user_id.to_s + "\n- 신고내용\n" + report_message.to_s + "\n- 신고대상: " + target_content.to_s
    noti_color = "#999999"
    slack_notifier(noti_title, noti_message, noti_color)
  end
  handle_asynchronously :report_submit_notifier

end
