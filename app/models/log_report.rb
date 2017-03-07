class LogReport < ActiveRecord::Base
  include SlackNotifier

  belongs_to :user

  after_create :report_submit_notifier

  def report_submit_notifier
    if target == 'ask'
      report_target = Ask.find(target_id)
      target_content = "[질문] #{report_target.message}"
      target_url = "#{CONFIG['host']}/asks/#{report_target.id}"
    elsif target == 'comment'
      report_target = Comment.find(target_id)
      target_content = "[댓글] #{report_target.content}"
      target_url = "#{CONFIG['host']}/asks/#{report_target.ask_id}"
    end

    report_message =
      if report_type == '1'
        '구매결정과는 무관한 내용이군요'
      elsif report_type == '2'
        '광고성, 홍보성이 짙은 내용이군요'
      elsif report_type == '3'
        '비윤리적인 내용은 보고싶지 않아요'
      elsif report_type == '4'
        "\n#{message}"
      end
    report_user = User.find(user_id)
    report_user_id = report_user.nil? ? '비회원' : report_user.string_id

    noti_title = "신고가 접수되었습니다\n#{target_url}"
    noti_message = "- 신고자 : #{report_user_id}\n- 신고내용 : #{report_message}\n- 신고대상 : \n#{target_content}"
    noti_color = '#999999'
    slack_notifier(noti_title, noti_message, noti_color)
  end
  handle_asynchronously :report_submit_notifier
end
