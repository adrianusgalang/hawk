require 'dotenv'
require 'telegram/bot'
require 'date'

class ListController < ApplicationController
  def metric
    @metrics = Metric.offset(10*(params[:id].to_f)).limit(10)

    @metrics.each do |r|
      if r.value_type != 3
        r.upper_threshold = HawkMain.hitungInvers(r.upper_threshold).to_s[0..8]
        r.lower_threshold = HawkMain.hitungInvers(r.lower_threshold).to_s[0..8]
      end
    end

    render json: @metrics.map do |metric|
      metric.to_hash
    end.to_json
    date_now = DateTime.now
    puts '{"Function":"list metrics", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  def alert
    @alerts = Alert.select('alerts.*','metrics.value_type','metrics.group','metrics.dimension','metrics.redash_id','metrics.time_column','metrics.value_column','metrics.time_unit','metrics.redash_title').joins('join metrics on alerts.metric_id = metrics.id').where(exclude_status: 0).order(date: :desc).offset(10*(params[:id].to_f)).limit(10)

    @alerts.each do |r|
      if r.value_type != 3
        r.value = HawkMain.hitungInvers(r.value).to_s[0..8]
      end
    end

    render json: @alerts.map do |alerts|
      alerts.to_hash
    end.to_json
    date_now = DateTime.now
    puts '{"Function":"list alerts", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end
end

class MetricsController < ApplicationController
  def all
    @metrics = Metric.where("redash_id LIKE :x OR redash_title LIKE :x OR value_column LIKE :x OR dimension_column LIKE :x OR dimension LIKE :x", x: "%" << params[:list_id] << "%").offset(10*(params[:metric_id].to_f)).limit(10)

    @metrics.each do |r|
      if r.value_type != 3
        r.upper_threshold = HawkMain.hitungInvers(r.upper_threshold).to_s[0..8]
        r.lower_threshold = HawkMain.hitungInvers(r.lower_threshold).to_s[0..8]
      end
    end

    render json: @metrics.map do |metric|
      metric.to_hash
    end.to_json
    date_now = DateTime.now
    puts '{"Function":"metric-all", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  def group
    @metrics = Metric.where("metrics.group = :x ", x: params[:list_id] ).offset(10*(params[:metric_id].to_f)).limit(10)

    @metrics.each do |r|
      if r.value_type != 3
        r.upper_threshold = HawkMain.hitungInvers(r.upper_threshold).to_s[0..8]
        r.lower_threshold = HawkMain.hitungInvers(r.lower_threshold).to_s[0..8]
      end
    end

    render json: @metrics.map do |metric|
      metric.to_hash
    end.to_json
    date_now = DateTime.now
    puts '{"Function":"metric-group", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end
end

class AlertsController < ApplicationController
  def all
    @alerts = Alert.select('alerts.*','metrics.value_type','metrics.group','metrics.dimension','metrics.redash_id','metrics.time_column','metrics.value_column','metrics.time_unit','metrics.redash_title').joins('join metrics on alerts.metric_id = metrics.id').order(date: :desc).where("exclude_status = 0 and (metrics.redash_id LIKE :x OR metrics.redash_title LIKE :x OR metrics.value_column LIKE :x OR metrics.dimension_column LIKE :x OR metrics.dimension LIKE :x)", x: "%" << params[:list_id] << "%").offset(10*(params[:alert_id].to_f)).limit(10)

    @alerts.each do |r|
      if r.value_type != 3
        r.value = HawkMain.hitungInvers(r.value).to_s[0..8]
      end
    end

    render json: @alerts.map do |alert|
      alert.to_hash
    end.to_json
    date_now = DateTime.now
    puts '{"Function":"alert-all", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  def group
    @alerts = Alert.select('alerts.*','metrics.value_type','metrics.group','metrics.dimension','metrics.redash_id','metrics.time_column','metrics.value_column','metrics.time_unit','metrics.redash_title').joins('join metrics on alerts.metric_id = metrics.id').order(date: :desc).where("exclude_status = 0 and metrics.group = :x ", x: params[:list_id] ).offset(10*(params[:alert_id].to_f)).limit(10)

    @alerts.each do |r|
      if r.value_type != 3
        r.value = HawkMain.hitungInvers(r.value).to_s[0..8]
      end
    end

    render json: @alerts.map do |alerts|
      alerts.to_hash
    end.to_json
    date_now = DateTime.now
    puts '{"Function":"alert-group", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end
end
