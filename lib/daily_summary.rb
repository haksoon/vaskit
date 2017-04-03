class DailySummary
  include SlackNotifier
  def send
    SlackNotifier.slack_notifier_daily_summary
  end
end
