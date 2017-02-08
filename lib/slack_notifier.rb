module SlackNotifier
  require 'slack-notifier'

  def slack_notifier(noti_title, noti_message, noti_color)
    config = YAML.load_file(Rails.root.join("config/slack.yml"))[Rails.env]
    notifier = Slack::Notifier.new config["webhook_url"], channel: config["channel"], username: "VASKIT"
    noti_color = "good" if noti_color == nil
    notifier.post text: noti_title, fallback: noti_title, attachments: [{ fallback: noti_title, text: noti_message, color: noti_color }]
  end

  def slack_notifier_alba(noti_title, noti_message, noti_color)
    config = YAML.load_file(Rails.root.join("config/slack.yml"))[Rails.env]
    notifier = Slack::Notifier.new config["webhook_url"], channel: "#97_new_asks", username: "VASKIT"
    noti_color = "good" if noti_color == nil
    notifier.post text: noti_title, fallback: noti_title, attachments: [{ fallback: noti_title, text: noti_message, color: noti_color }]
  end
end
