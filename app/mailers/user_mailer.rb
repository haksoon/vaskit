# coding : utf-8
class UserMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers
  default from: 'notice@vaskit.kr'

  def send_notice(user, notice)
    @message = notice.message
    mail(to: user.email, subject: notice.title).deliver
  end

  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end
end
