class Metric < ApplicationRecord

	has_many :alerts

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
