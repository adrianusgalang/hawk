require 'json'
class DashboardController < ApplicationController


	def summary
		metrics = Metric.all
		total_metrics = metrics.count

		alerts = Alert.all
		total_alerts = alerts.count

		most_metrics_alert= 'gmv daily'

		average_alert_daily = average_alert_daily(alerts)
		average_alert_weekly = 1000

		graph_data_daily = Statistic.calculate_alert_graph_data_daily(alerts)
		graph_data_weekly = Statistic.calculate_alert_graph_data_weekly(alerts)

    render json: {
      total_metrics: total_metrics,
      total_alerts: total_alerts,
      most_metrics_alert: most_metrics_alert,
      graph_data_daily: graph_data_daily,
      graph_data_weekly: graph_data_weekly
    }.to_json
	end

end
