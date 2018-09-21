require 'date'

class AlertController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:index, :confirmuser]

  def index
    alerts = Alert.select('alerts.*','metrics.redash_id','metrics.time_unit','metrics.redash_title').joins('join metrics on alerts.metric_id = metrics.id').where(exclude_status: 0)
    render json: alerts.map do |alert|
      puts alert.metric_id
      alert.to_hash
    end.to_json
  end

  def confirmuser
    alert = Alert.where(id: params[:alert][:alert_id])
    metric = Metric.where(id: alert[0].metric_id)
    redash_id = metric[0].redash_id
    time_column = metric[0].time_column
    value_column = metric[0].value_column
    time_unit = metric[0].time_unit
    value_type = metric[0].value_type

    ratio,value = Redash.calculate_median(redash_id,alert[0].date,time_unit,time_column,value_column,time_unit,value_type)

    dateExclude = DateExc.new
    dateExclude.date = alert[0].date
    dateExclude.time_unit = time_unit
    dateExclude.ratio = ratio
    dateExclude.value = value
    dateExclude.redash_id = redash_id
    dateExclude.note = metric[0].id
    dateExclude.save
    alert.update(exclude_status: params[:alert][:set_to])
  end
end