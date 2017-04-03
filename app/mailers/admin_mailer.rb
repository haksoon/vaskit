class AdminMailer < ActionMailer::Base
  default from: %("VASKIT admin" <notice@vaskit.kr>),
          to: ['junsikahn@vaskit.kr',
               'haksoon@vaskit.kr',
               'seokkiyoon@vaskit.kr',
               'sunghomoon@vaskit.kr',
               'emma@vaskit.kr']

  def client_error(log)
    @log = log
    mail(from: %("Client Error" <notice@vaskit.kr>),
         to: ['junsikahn@vaskit.kr', 'sunghomoon@vaskit.kr'],
         subject: "[Client ERROR] #{log.error_message}")
  end
end
