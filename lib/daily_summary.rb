class DailySummary
  include SlackNotifier
  def self.send
    SlackNotifier.slack_notifier_daily_summary
  end
end
