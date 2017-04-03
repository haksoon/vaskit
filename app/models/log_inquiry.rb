class LogInquiry < ActiveRecord::Base
  include SlackNotifier

  belongs_to :user

  after_create :inquiry_submit_notifier

  def inquiry_submit_notifier
    inquiry_user = User.find(user_id)
    inquiry_user_id = inquiry_user.nil? ? '비회원' : inquiry_user.string_id

    noti_channel = YAML.load_file(Rails.root.join('config/slack.yml'))[Rails.env]['etc_channel']
    noti_title = '문의가 접수되었습니다'
    noti_message = "- 내용\n#{message}\n- 연락처: #{contact} (#{inquiry_user_id})"
    noti_color = '#999999'
    slack_notifier(noti_channel, noti_title, noti_message, noti_color)
  end
  handle_asynchronously :inquiry_submit_notifier
end
