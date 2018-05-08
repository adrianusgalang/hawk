class Statistic
  def self.calculate_alert_graph_data_daily(alerts)
    result = alerts
      .order('created_date ASC')
      .group('created_date')  
      .select("DATE(created_at) AS created_date, COUNT(id) AS counts")
    return result.map do |row|
      {x: "#{row.created_date.day}-#{row.created_date.month}-#{row.created_date.year}", y: row.counts}
    end
  end

  def self.calculate_alert_graph_data_weekly(alerts)
    result = alerts
      .order('created_date ASC')
      .group('created_date')
      .select("DATE_SUB(created_at, INTERVAL DAYOFWEEK(created_at)-1 DAY) AS created_date, COUNT(id) AS counts")
    return result.map do |row|
      {x: "#{row.created_date.day}-#{row.created_date.month}-#{row.created_date.year}", y: row.counts, was_alert: [true, false].sample}
    end
  end

  # def self.average_alert_daily(alerts)
  #   result = alerts.group('DATE(created_at)').average
  #   return result
  # end

  # def self.average_alert_weekly(alerts)
  #   result = alerts.group('DATE(created_at)').average
  #   return result
  # end

end