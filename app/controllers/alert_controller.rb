require 'date'

class AlertController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:index, :confirmuser]

  def index
    alerts = Alert.select('alerts.*','metrics.value_type','metrics.group','metrics.dimension','metrics.redash_id','metrics.time_column','metrics.value_column','metrics.time_unit','metrics.redash_title').joins('join metrics on alerts.metric_id = metrics.id').where(exclude_status: 0).order(date: :desc)

    alerts.each do |r|
      if r.value_type != 3 && r.value_type != 4
        r.value = HawkMain.hitungInvers(r.value).to_s[0..8]
      end
    end

    # render json: alerts.map do |alert|
    #   alert.to_hash
    # end.to_json

    render json: {
      data: alerts,
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"alert-index", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  def confirmuser
    cortabot = Cortabot.new()
    cortabot.hawk_loging("add date exclude",params[:alert][:alert_id])

    alert = Alert.where(id: params[:alert][:alert_id])
    metric = Metric.where(id: alert[0].metric_id)
    redash_id = metric[0].redash_id
    time_column = metric[0].time_column
    value_column = metric[0].value_column
    time_unit = metric[0].time_unit
    value_type = metric[0].value_type
    dimension_column = metric[0].dimension_column
    dimension = metric[0].dimension

    if dimension_column != nil
      ratio,value = Redash.calculate_median_dimension(redash_id,alert[0].date,time_unit,time_column,value_column,time_unit,value_type,dimension, dimension_column,metric[0].redash)
    else
      ratio,value = Redash.calculate_median(redash_id,alert[0].date,time_unit,time_column,value_column,time_unit,value_type,metric[0].redash)
    end

    dateExclude = DateExc.new
    dateExclude.date = alert[0].date
    dateExclude.time_unit = time_unit
    dateExclude.ratio = ratio
    dateExclude.value = value
    dateExclude.redash_id = redash_id
    dateExclude.metric_id = metric[0].id
    dateExclude.save
    alert.update(exclude_status: params[:alert][:set_to])
    MetricController.update_threshold_use_param(metric[0].id)

    render json: {
      message: "confirm user dimension ok",
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"confirmuser", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  def test_tele
    cortabot = Cortabot.new()
    cortabot.test_cortabot(params[:chatid])
    render json: {
      message: "test tele ok",
      meta: {
        "http_status": 200
      }
    }.to_json
  end
end
