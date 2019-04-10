require 'json'
require 'httparty'

class DashboardController < ApplicationController
	skip_before_action :verify_authenticity_token, :only => [:summary, :alert, :dateexclude, :adddateexclude, :removedateexclude]

	def summary
		metrics = Metric.all
		total_metrics = metrics.count

		alerts = Alert.all
		total_alerts = alerts.count

		most_metrics_alert= Statistic.max_metric()

		average_alert_daily = Statistic.average_alert_daily(alerts)
		average_alert_weekly = Statistic.average_alert_weekly(alerts)

		graph_data_daily = Statistic.calculate_alert_graph_data_daily(alerts)
		graph_data_weekly = Statistic.calculate_alert_graph_data_weekly(alerts)

    render json: {
      data: {
				total_metrics: total_metrics,
				total_alerts: total_alerts,
				most_metrics_alert: most_metrics_alert,
				graph_data_daily: graph_data_daily,
				graph_data_weekly: graph_data_weekly
			},
			meta: {
				"http_status": 200
			}
    }.to_json
	end

end
