require 'json'
class HawkPython

	# HAWK_PATH = File.join(Rails.root, 'hawk_python')
  HAWK_PATH = Rails.root.join('hawk_python')

	def self.set_threshold(redash_id, time_column, value_column, value_type)
		result = `python3 #{HAWK_PATH}/set_threshold.py #{redash_id} #{time_column} #{value_column} #{value_type}`
    Rails.logger.info(result)
    return JSON.parse(result)
  end

  def self.update_threshold(redash_id, time_column, value_column, value_type, mean = 'NaN', flag = 'NaN', new_flag = 'NaN')
    result = `python3 #{HAWK_PATH}/update_threshold.py #{redash_id} #{time_column} #{value_column} #{time_unit} #{value_type} #{mean} #{flag} #{new_flag}`
    Rails.logger.info(result)
    return JSON.parse(result)
  end

  def self.send_alert_hawk(redash_id, time_column, value_column, time_unit, value_unit, upper_threshold, lower_threshold)
  	result = `python3 #{HAWK_PATH}/send_alert.py #{redash_id} #{time_column} #{value_column} #{time_unit} #{value_unit} #{upper_threshold} #{lower_threshold}`
    Rails.logger.info(result)
    
    if result['is_alert']
    	metric = Metric.where(redash_id: redash_id).first
    	Alert.create(value: result['value'], is_upper: result['is_upper'], metric: metric)
    end
    return JSON.parse(result)
  end

  def self.test_python
    puts HAWK_PATH
    result = `python3 #{HAWK_PATH}/test.py lalalala`
    puts "tes hawk python-------"
    puts result
    # Rails.logger.info(result)
    # puts(result.to_h)
    res = JSON.parse(result)
    return res
  end

end
