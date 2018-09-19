require 'rufus-scheduler'
require 'dotenv'

scheduler = Rufus::Scheduler::singleton

# test scheduler
scheduler.in '2s' do
  metricController = MetricController.new()
  # metricController.get_alert('hourly')
  puts "===================== D - O - N - E ===================="
end

scheduler.every '60s' do
  metricController = MetricController.new()
  metricController.checkErrorThread()
end

scheduler.cron '30 * * * *' do
  metricController = MetricController.new()
  metricController.get_alert('hourly')
end

scheduler.cron '0 4 * * *' do

  metricController = MetricController.new()
  metricController.get_alert('daily')
end

scheduler.cron '0 9 * * 5' do
  metricController = MetricController.new()
  metricController.get_alert('weekly')
end

scheduler.cron '0 9 1 * *' do
  metricController = MetricController.new()
  metricController.get_alert('monthly')
end
