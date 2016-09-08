# coding : utf-8
class UserMailer < ActionMailer::Base
  default from: %{"VASKIT" <notice@vaskit.kr>}

  def welcome_email(user)
    @user = user
    @ask_count = Ask.all.count
    @vote_count = Vote.all.count
    @commnent_count = Comment.all.count
    mail(to: user.email, subject: "[VASKIT] #{user.string_id}님, 환영합니다!").deliver
  end

  def send_notice(user, notice)
    @message = notice.message
    mail(to: user.email, subject: notice.title).deliver
  end
end
