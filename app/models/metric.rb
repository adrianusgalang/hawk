class Metric < ApplicationRecord

	has_many :alerts


	def update_threshold
		threshold = HawkPython.get_threshold(self.redash_id, self.time_column, self.value_column, self.time_unit, self.value_unit)
		self.upper_threshold = threshold[:upper_threshold]
		self.lower_threshold = threshold[:lower_threshold]
	end

	def send_alert
		HawkPython.send_alert_hawk(self.redash_id, self.time_column, self.value_column, self.time_unit, self.value_unit, self.upper_threshold, self.lower_threshold)
	end


end
