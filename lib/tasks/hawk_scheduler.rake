namespace :hawkscheduler do
	

	task :alerting_daily => :environment do
		metrics = Metric.where(time_unit: 'daily')
		metrics.map { |r|
			HawkPython.send_alert_hawk(r.redash_id, r.time_column, r.value_column, r.time_unit, r.value_type, r.upper_threshold, r.lower_threshold)
		}
		print('done!')
	end
	task :alerting_weekly => :environment do
		metrics = Metric.where(time_unit: 'weekly')
		metrics = Metric.all
		metrics.map { |r|
			HawkPython.send_alert_hawk(r.redash_id, r.time_column, r.value_column, r.time_unit, r.value_type, r.upper_threshold, r.lower_threshold)
		}
		print('done!')
	end
	task :alerting_monthly => :environment do
		metrics = Metric.where(time_unit: 'monthly')
		metrics = Metric.all
		metrics.map { |r|
			HawkPython.send_alert_hawk(r.redash_id, r.time_column, r.value_column, r.time_unit, r.value_type, r.upper_threshold, r.lower_threshold)
		}
		print('done!')
	end
	task :alerting_hourly => :environment do
		metrics = Metric.where(time_unit: 'hourly')
		metrics = Metric.all
		metrics.map { |r|
			HawkPython.send_alert_hawk(r.redash_id, r.time_column, r.value_column, r.time_unit, r.value_type, r.upper_threshold, r.lower_threshold)
		}
		print('done!')
	end

	task :update_daily => :environment do
		metrics = Metric.where(time_unit: 'daily')
		metrics.map { |r|
			HawkPython.update_threshold(r.redash_id, r.time_column, r.value_column, r.value_type)
		}
		print('done!')
	end

	task :update_weekly => :environment do
		metrics = Metric.where(time_unit: 'weekly')
		metrics.map { |r|
			HawkPython.update_threshold(r.redash_id, r.time_column, r.value_column, r.value_type)
		}
		print('done!')
	end

	task :update_monthly => :environment do
		metrics = Metric.where(time_unit: 'monthly')
		metrics.map { |r|
			HawkPython.update_threshold(r.redash_id, r.time_column, r.value_column, r.value_type)
		}
		print('done!')
	end

	task :update_hourly => :environment do
		metrics = Metric.where(time_unit: 'hourly')
		metrics.map { |r|
			HawkPython.update_threshold(r.redash_id, r.time_column, r.value_column, r.value_type)
		}
		print('done!')
	end
end