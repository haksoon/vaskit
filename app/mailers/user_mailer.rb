# coding : utf-8
class UserMailer < ActionMailer::Base
  default from: 'vaskit@vaskit.kr'
  
  def send_notice(user, notice)
    @message = notice.message
    mail(to: user.email, subject: notice.title).deliver
  end
end
