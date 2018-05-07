class HawkPython

	HAWK_PATH = File.join(Rails.root, 'hawk_python')

	def self.get_threshold(redash_id, time_column, value_column, time_unit, value_unit)
		result = `python3 "#{HAWK_PATH}/get_threshold.py" "#{redash_id}, #{time_column}, #{value_column}, #{time_unit}, #{value_unit}"`
    Rails.logger.info(result)
    return result.to_h
  end

  def self.send_alert_hawk(redash_id, time_column, value_column, time_unit, value_unit, upper_threshold, lower_threshold)
  	result = `python3 "#{HAWK_PATH}/send_alert.py" "#{redash_id}, #{time_column}, #{value_column}, #{time_unit}, #{value_unit}, #{upper_threshold}, #{lower_threshold}"`
    Rails.logger.info(result)
    
    if result[:is_alert]
    	metric = Metric.where(redash_id: redash_id).first
    	Alert.create(value: result[:value], is_upper: result[:is_upper], metric: metric)
    end
    return result_hash = result.to_h
  end

  def self.test_python
    result = `python "#{HAWK_PATH}/test.py lalala"`
    Rails.logger.info(result)
    return result
  end

end
