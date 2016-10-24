# coding : utf-8
class UserMailer < ActionMailer::Base
  default from: %{"VASKIT" <notice@vaskit.kr>}

  def welcome_email(user)
    @user = user
    @ask_count = Ask.all.count.to_s.gsub(/(\d)(?=(?:\d\d\d)+(?!\d))/, '\1,')
    @vote_count = Vote.all.count.to_s.gsub(/(\d)(?=(?:\d\d\d)+(?!\d))/, '\1,')
    @comment_count = Comment.all.count.to_s.gsub(/(\d)(?=(?:\d\d\d)+(?!\d))/, '\1,')
    mail(to: user.email, subject: "[VASKIT] #{user.string_id}님, 환영합니다!")
  end

  def send_notice(user, notice)
    @message = notice.message
    mail(to: user.email, subject: notice.title)
  end
end
