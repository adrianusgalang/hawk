class Statistic
  def self.calculate_alert_graph_data(alerts)
    result = alerts
      .order('created_date ASC')
      .group('created_date')
      .select("DATE(created_at) AS created_date, COUNT(id) AS counts")
    return result.map do |row|
      {x: "#{row.created_date.day}-#{row.created_date.month}-#{row.created_date.year}", y: row.counts}
    end
  end

  def self.calculate_alert_graph_data2(alerts)
    # terima fungsi get redash
    result = alerts
      .order('created_date ASC')
      .group('created_date')
      .select("DATE(created_at) AS created_date, COUNT(id) AS counts")
    return result.map do |row|
      {x: "#{row.created_date.day}-#{row.created_date.month}-#{row.created_date.year}", y: row.counts, was_alert: [true, false].sample}
    end
  end
end