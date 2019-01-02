class Statistic
  def self.calculate_alert_graph_data_daily(alerts)
    start_date = Time.zone.now - 1.month
    end_date = Time.zone.now
    result = alerts
      .order('created_date ASC')
      .group('created_date')
      .select("DATE(created_at) AS created_date, COUNT(id) AS counts")
      .where('created_at >= ? AND created_at < ?', start_date, end_date)
    return result.map do |row|
      {x: "#{row.created_date.day}-#{row.created_date.month}-#{row.created_date.year}", y: row.counts}
    end
  end

  def self.calculate_alert_graph_data_weekly(alerts)
    start_date = Time.zone.now - 2.month
    end_date = Time.zone.now
    result = alerts
      .order('week ASC')
      .group('week')
      .select("date(created_at-interval (dayofweek(created_at)+1)%7 day) AS week, count(id) as counts")
      .where('created_at >= ? AND created_at < ?', start_date, end_date)
    return result.map do |row|
      {x: "#{row.week.day}-#{row.week.month}-#{row.week.year}", y: row.counts, was_alert: [true, false].sample}
    end
  end

  def self.average_alert_daily(alerts)
    start_date = Time.zone.now - 1.month
    end_date = Time.zone.now
    result = alerts
      .order('created_date ASC')
      .group('created_date')
      .select("DATE(created_at) AS created_date, COUNT(id) AS counts")
      .where('created_at >= ? AND created_at < ?', start_date, end_date)
    sum = 0
    result.each do |p|
      sum = p.counts + sum
    end
    if result.length != 0
      return sum/result.length
    else
      return 0
    end
  end

  def self.average_alert_weekly(alerts)
    start_date = Time.zone.now - 2.month
    end_date = Time.zone.now
    result = alerts
      .order('created_date ASC')
      .group('created_date')
      .select("DATE_SUB(created_at, INTERVAL DAYOFWEEK(created_at)-1 DAY) AS created_date, COUNT(id) AS counts")
      .where('created_at >= ? AND created_at < ?', start_date, end_date)
    sum = 0
    result.each do |p|
      sum = p.counts + sum
    end
    if result.length != 0
      return sum/result.length
    else
      return 0
    end
  end

  def self.max_metric()
    start_date = Time.zone.now - 1.month
    end_date = Time.zone.now
    return Metric.select('redash_title, count(alerts.id) as cnt').joins(:alerts).where('alerts.created_at >= ? AND alerts.created_at < ?', start_date, end_date).group(:id).order('cnt desc').first
    # return Metric.select('redash_title, count(alerts.id) as cnt').joins(:alerts).group(:id).order('cnt desc').first.redash_title
  end

end
