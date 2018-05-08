require 'json'
class HawkPython

	# HAWK_PATH = File.join(Rails.root, 'hawk_python')
  HAWK_PATH = Rails.root.join('hawk_python')

	def self.set_threshold(redash_id, time_column, value_column, value_type)
		result = `python #{HAWK_PATH}/set_threshold.py #{redash_id} #{time_column} #{value_column} #{value_type}`
    # return expectation: upper_threshold, lower_threshold, mean, ourlier_suspected
    Rails.logger.info(result)
    return JSON.parse(result)
  end

  def self.update_threshold(redash_id, time_column, value_column, value_type, mean = 'NaN', flags = 'NaN', new_flag = 'NaN')
    result = `python #{HAWK_PATH}/update_threshold.py #{redash_id} #{time_column} #{value_column} #{value_type} #{mean} #{flags} #{new_flag}`
    # return expectation: upper_threshold, lower_threshold, mean, ourlier_suspected, flags

    Rails.logger.info(result)
    return JSON.parse(result)
  end

  def self.send_alert_hawk(redash_id, time_column, value_column, value_type, time_unit, upper_threshold, lower_threshold, time_now, email)
  	result = `python #{HAWK_PATH}/send_alert.py #{redash_id} #{time_column} #{value_column} #{value_type} #{time_unit} #{upper_threshold} #{lower_threshold} #{time_now} #{email}`
    # return expectation: is_alert, is_upper, value
    result = JSON.parse(result)
    Rails.logger.info(result)
    print(result)
    print('aksjhdakjsd')
    print(result["is_alert"])
    print(result["value"])
    
    if result['is_alert']
    	metric = Metric.where(redash_id: redash_id).first
      print('ini value')
      print(result['value'])
    	Alert.create(value: result['value'], is_upper: result['is_upper'], metric: metric)
    end
    return result
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
