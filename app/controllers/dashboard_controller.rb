require 'json'
class DashboardController < ApplicationController


	def summary
		metrics = Metric.all
		total_metrics = metrics.count

		alerts = Alert.all
		total_alerts = alerts.count

		most_metrics_alert= 'gmv daily'

		graph_data = Statistic.calculate_alert_graph_data(alerts)

    render json: {
      total_metrics: total_metrics,
      total_alerts: total_alerts,
      most_metrics_alert: most_metrics_alert,
      graph_data: graph_data
    }.to_json
	end

end
