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

# Learn more: http://github.com/javan/whenever


every 1.day, at: '12:15 pm' do
  rake "hawkscheduler:alerting_daily"
  rake "hawkscheduler:alerting_hourly"
end

every :friday, at: '09:00 am' do
  rake "hawkscheduler:alerting_weekly"
  rake "hawkscheduler:update_daily"
end

every '0 0 1 * *' do
  rake "hawkscheduler:alerting_monthly"
  rake "hawkscheduler:update_weekly"
end

every '0 * * * *' do
  rake "hawkscheduler:alerting_hourly"
end


