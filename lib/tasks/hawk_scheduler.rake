namespace :hawkscheduler do
	

	task :alerting => :environment do
		metrics = Metric.all
		metrics.map { |r|
			HawkPython.send_alert_hawk(r.redash_id, r.time_column, r.value_column, r.time_unit, r.value_type, r.upper_threshold, r.lower_threshold)
		}
	end

	task :update_daily => :environment do
		metrics = Metric.where(time_unit: 'daily')
		metrics.map { |r|
			HawkPython.update_threshold(r.redash_id, r.time_column, r.value_column, r.value_type)
		}
	end
end