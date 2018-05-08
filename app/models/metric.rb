class Metric < ApplicationRecord

	has_many :alerts


	def update_threshold
		threshold = HawkPython.update_threshold(self.redash_id, self.time_column, self.value_column, self.value_type, self.time_unit)
		self.upper_threshold = threshold['upper_threshold']
		self.lower_threshold = threshold['lower_threshold']
	end

  def set_threshold
    threshold = HawkPython.set_threshold(self.redash_id, self.time_column, self.value_column, self.time_unit, self.value_type)
    self.upper_threshold = threshold['upper_threshold']
    self.lower_threshold = threshold['lower_threshold']
  end

	def send_alert
		HawkPython.send_alert_hawk(self.redash_id, self.time_column, self.value_column, self.time_unit, self.value_type, self.upper_threshold, self.lower_threshold)
	end

	def to_hash
    {
      redash_id: self.redash_id,
      time_column: self.time_column,
      value_column: self.value_column,
      time_unit: self.time_unit,
      value_type: self.value_type
    }
  end

  def to_json
    to_hash.to_json
  end


end
