class Statistic
  def self.calculate_order_graph_data(metrics)
    result = metrics
      .order('created_date ASC')
      .group('created_date')
      .select("DATE(created_at) AS created_date, COUNT(id) AS counts")
    return result.map do |row|
      {x: "#{row.created_date.day}-#{row.created_date.month}-#{row.created_date.year}", y: row.counts}
    end
  end
end