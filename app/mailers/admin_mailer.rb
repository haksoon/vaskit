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

  def daily_summary(user_summaries, daily_summaries)
    @user_summaries = user_summaries
    @daily_summaries = daily_summaries
    date = Time.now.year.to_s + "년 "+ Time.now.month.to_s + "월 " + Time.now.day.to_s + "일"
    mail(subject: "[VASKIT] #{date} 일일 리포트").deliver
  end

end
