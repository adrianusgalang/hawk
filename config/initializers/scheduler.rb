require 'rufus/scheduler'
require 'dotenv'

scheduler = Rufus::Scheduler::singleton

# test scheduler
scheduler.in '2s' do
  # metricController = MetricController.new()
  # metricController.get_alert('daily')
  puts "===================== D - O - N - E ===================="
end

scheduler.every '60s' do
  metricController = MetricController.new()
  metricController.checkErrorThread()
end

scheduler.every '3600s' do
  metricController = MetricController.new()
  metricController.removeErrorThread()
end

scheduler.cron '25 * * * *' do
  metricController = MetricController.new()
  metricController.get_alert(0)
end

scheduler.cron '1 4 * * *' do
  metricController = MetricController.new()
  metricController.get_alert(1)
end

scheduler.cron '0 9 * * 5' do
  metricController = MetricController.new()
  metricController.get_alert(2)
end

scheduler.cron '0 9 1 * *' do
  metricController = MetricController.new()
  metricController.get_alert(3)
end
