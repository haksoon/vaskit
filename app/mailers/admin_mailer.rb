class AdminMailer < ActionMailer::Base
  default from: 'notice@vaskit.kr',
          to: ['junsikahn@vaskit.kr', 'haksoon@vaskit.kr', 'seokkiyoon@vaskit.kr']

  def inquiry_submitted(inquiry)
    @inquiry = inquiry
    mail(subject: "[VASKIT] 문의가 접수되었습니다.").deliver
  end

  def report_submitted(report)
    @report = report
    mail(subject: "[VASKIT] 신고가 접수되었습니다.").deliver
  end
end
