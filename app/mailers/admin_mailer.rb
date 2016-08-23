class AdminMailer < ActionMailer::Base
  default from: 'notice@vaskit.kr'

  def inquiry_submitted(inquiry)
    @inquiry = inquiry
    mail(to: "notice@vaskit.kr", subject: "[VASKIT] 문의가 접수되었습니다.").deliver
  end

  def report_submitted(report)
    @report = report
    mail(to: "notice@vaskit.kr", subject: "[VASKIT] 신고가 접수되었습니다.").deliver
  end
end
