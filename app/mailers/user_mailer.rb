# coding : utf-8
class UserMailer < ActionMailer::Base
  default from: 'notice@vaskit.kr'

  def welcome_email(user)
    @url  = 'http://vaskit.kr/etc/landing'
    mail(to: user.email, subject: 'Welcome to VASKIT')
  end

  def send_notice(user, notice)
    @message = notice.message
    mail(to: user.email, subject: notice.title).deliver
  end
end
