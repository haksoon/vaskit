# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

set :environment, :production
set :bundler_path, '/home/darammg/.rvm/gems/ruby-2.2.3/bin/bundle'
set :output, error: 'log/error.log', standard: 'log/cron.log'

every 1.day, at: '12:00 am' do
  runner 'SlackNotifier.slack_notifier_daily_summary'
end

every 1.day, at: '06:00 am' do
  runner 'UserActivityScore.weekly_update_user_grade'
end

# Learn more: http://github.com/javan/whenever
