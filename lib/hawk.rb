class Hawk

	HAWK_PATH = File.join(Rails.root, 'hawk')

	def get_threshold(redash_id, time_column, value_column, time_unit, value_unit)
		result = `python3 "#{HAWK_PATH}/get_threshold.py" "#{redash_id}, #{time_column}, #{value_column}, #{time_unit}, #{value_unit}"`
    Rails.logger.info(result)
    return result.to_h
  end

  def send_alert_hawk(redash_id, time_column, value_column, time_unit, value_unit, upper_threshold, lower_threshold)
  	result = `python3 "#{HAWK_PATH}/send_alert.py" "#{redash_id}, #{time_column}, #{value_column}, #{time_unit}, #{value_unit}, #{upper_threshold}, #{lower_threshold}"`
    Rails.logger.info(result)
    result_hash = result.to_h
    
    if result[:is_alert]
    	metric = Metric.where(redash_id: redash_id).first
    	Alert.create(value: result[:value], is_upper: result[:is_upper], metric: metric)
    end
  end


end
