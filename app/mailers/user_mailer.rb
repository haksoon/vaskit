class UserMailer < ActionMailer::Base
  default from: %{"VASKIT" <notice@vaskit.kr>}

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "[VASKIT] #{user.string_id}님, 환영합니다!")
  end

  def notice_email(user, notice)
    @title = notice.title
    @message = notice.message.html_safe
    mail(to: user.email, subject: notice.title)
  end
end
