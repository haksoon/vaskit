# coding : utf-8
class UserMailer < ActionMailer::Base
  default from: 'notice@vaskit.kr'

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "[VASKIT] #{user.string_id}님, 환영합니다!")
  end

  def send_notice(user, notice)
    @message = notice.message
    mail(to: user.email, subject: notice.title).deliver
  end
end
