class SummaryMailer
  def self.daily_summary
    AdminMailer.daily_summary.deliver_now
  end
end
