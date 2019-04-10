require 'date'

class DateExcludeController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:index, :removedateexclude]

  def index
    dateexcs = DateExc.select('date_excs.*','metrics.value_type','metrics.redash_id','metrics.dimension','metrics.group','metrics.time_column','metrics.value_column','metrics.time_unit','metrics.redash_title').joins('join metrics on date_excs.metric_id = metrics.id').order(date: :desc)

    dateexcs.each do |r|
      if r.value_type != 3
        r.ratio = HawkMain.hitungInvers(r.ratio).to_s[0..8]
      end
    end

    # render json: dateexcs.map do |dateexc|
		# 	dateexc.to_hash
    # end.to_json
    
    render json: {
      data: dateexcs,
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"dateExclude-index", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  def removedateexclude
    cortabot = Cortabot.new()
    cortabot.hawk_loging("remove exclude",params[:date][:id])

    dateexcs = DateExc.where(id: params[:date][:id]).first
    metric = dateexcs.metric_id
    alert = Alert.where(date: dateexcs.date, metric_id: dateexcs.metric_id, exclude_status: 1)
    alert.update(exclude_status: 0)
    dateexcs.delete
    MetricController.update_threshold_use_param(metric)

    render json: {
      message: "remove date exclude ok",
      meta: {
        "http_status": 200
      }
    }.to_json
    date_now = DateTime.now
    puts '{"Function":"removedateexclude", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

end
