class DashboardController < ApplicationController


	def summary
		@metrics = Metric.all
		@total_metrics = @metrics.count

		@alerts = Alert.all
		@total_alerts = @alerts.count

		@most_metric_alert = 'gmv daily'
	end

end
