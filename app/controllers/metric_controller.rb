class MetricController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create, :update_all, :update_threshold, :update, :delete, :update_all]

  def statistic
    @metric = Metric.where(redash_id: params[:id]).first

    if params[:start]
      start_date = Time.zone.parse(params[:start]).beginning_of_day
    else
      start_date = Time.zone.now - 1.month
    end
    if params[:end]
      end_date = Time.zone.parse(params[:end]).end_of_day
    else
      end_date = Time.zone.now
    end

    alerts = @metric.alerts.where('alerts.created_at >= ? AND alerts.created_at < ?', start_date, end_date)

    total_alert = alerts.count
    total_upper_alert = alerts.where(is_upper: true).count
    total_lower_alert = alerts.where(is_upper: false).count
    maximum_value = alerts.where(is_upper: true).maximum(:value)
    average_upper_value = alerts.where(is_upper: true).average(:value)
    minimum_value = alerts.where(is_upper: false).maximum(:value)
    average_lower_value = alerts.where(is_upper: false).average(:value)
    graph_data_daily = Statistic.calculate_alert_graph_data_daily(alerts)
    graph_data_weekly = Statistic.calculate_alert_graph_data_weekly(alerts)

    render json: {
          total_alert: total_alert,
          total_upper_alert: total_upper_alert,
          total_lower_alert: total_lower_alert,
          maximum_value: maximum_value,
          average_upper_value: average_upper_value,
          minimum_value: minimum_value,
          average_lower_value: average_lower_value,
          graph_data_daily: graph_data_daily,
          graph_data_weekly: graph_data_weekly
        }.to_json
  end

  

  def manage
    @metrics = Metric.all
    render json: @metrics.map do |metric|
      metric.to_hash
    end.to_json

  end

  def update_all
    metrics = Metric.all
    metrics.map { |r| r.update_threshold }
  end

  def update_threshold
    metric = Metric.where(redash_id: params[:id]).first
    response, threshold = metric.update_threshold
    render json: {
      response: response,
      upper_threshold: threshold[:upper_threshold],
      lower_threshold: threshold[:lower_threshold]
    }
  end

  def edit
    metric = Metric.where(redash_id: params[:id]).first
    render json: metric.to_json
  end

  def update
    metric = Metric.where(redash_id: params[:id]).first
    metric.update(resource_params)
  end

  def delete
    metric = Metric.where(redash_id: params[:id]).first
    metric.destroy
  end

  def new

  end

  def create
    metric = Metric.create(resource_params)
    create_status = true
    if Metric.where(redash_id: params[:redash_id]).nil?
      create_status = false
    end
    response = metric.set_threshold
    status = 'failed'
    if create_status and response
      status = 'ok'
    end
    
    json_res = metric.to_hash
    json_res['response'] = status

    render json: json_res

  end

  def resource_params
    params.require(:metric).permit(:redash_id, :time_column, :value_column, :time_unit, :value_type, :email)
  end
end
