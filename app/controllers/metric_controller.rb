require 'dotenv'
require 'telegram/bot'
require 'date'

class MetricController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create, :update_all, :update_threshold, :update, :delete, :update_all, :confirmuser]
  $threadCount = 0
  $threadLimit = ENV["THREAD_LIMIT"].to_f
  include Prometheus::Controller

  def statistic
    @metric = Metric.where(id: params[:id]).first

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

    date_now = DateTime.now
    puts '{"Function":"statistic", "Date": "'+date_now.to_s+'", "Status": "ok"}'

    if @metric.value_type != 3 && @metric.value_type != 4
      maximum_value = HawkMain.hitungInvers(maximum_value).to_s[0..8]
      average_upper_value = HawkMain.hitungInvers(average_upper_value).to_s[0..8]
      minimum_value = HawkMain.hitungInvers(minimum_value).to_s[0..8]
      average_lower_value = HawkMain.hitungInvers(average_lower_value).to_s[0..8]
    else
      maximum_value = maximum_value
      average_upper_value = average_upper_value
      minimum_value = minimum_value
      average_lower_value = average_lower_value
    end

    render json: {
      data:{
        total_alert: total_alert,
        total_upper_alert: total_upper_alert,
        total_lower_alert: total_lower_alert,
        maximum_value: maximum_value,
        average_upper_value: average_upper_value,
        minimum_value: minimum_value,
        average_lower_value: average_lower_value,
        graph_data_daily: graph_data_daily,
        graph_data_weekly: graph_data_weekly
      },
      meta: {
        "http_status": 200
      }
    }.to_json
  end

  def manage
    @metrics = Metric.all.order("id desc")

    @metrics.each do |r|
      if r.value_type != 3 && r.value_type != 4
        r.upper_threshold = HawkMain.hitungInvers(r.upper_threshold).to_s[0..8]
        r.lower_threshold = HawkMain.hitungInvers(r.lower_threshold).to_s[0..8]
      end
    end

    render json: {
      data: @metrics,
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"manage", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  def update_all
    cortabot = Cortabot.new()
    cortabot.hawk_loging("update all threshold","FE")
    isfinish = 0
    metrics = Metric.where("value_type != 3 and value_type != 4 and on_off = 1")
    metrics.each do |r|
      checkThread()
      $threadCount = $threadCount + 1
      Thread.new{
        query = r.redash_id
        time_column = r.time_column
        value_column = r.value_column
        time_unit = r.time_unit
        value_type = r.value_type
        dimension_column = r.dimension_column
        dimension = r.dimension

        if dimension_column != nil
          batas_bawah,batas_atas = Redash.get_csv_dimension(query, time_column, value_column, time_unit, value_type, r.id, dimension, dimension_column,r.redash)
        elsif value_type != 3 && value_type != 4
          batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, r.id,r.redash)
        else
          batas_atas = r.upper_threshold
          batas_bawah = r.lower_threshold
        end

        redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(query,r.redash)
        redash_schedule = getRedashSchedule(time_unit)
        if time_unit < 4
          redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
        else
          redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 60).second
        end
        if batas_atas != 0 && batas_bawah != 0 || value_type == 3 || value_type == 4
          r.update(upper_threshold: batas_atas,lower_threshold:batas_bawah,redash_title:redash_title,group:getRedashTitle(redash_title),next_update:redash_update_at,schedule:redash_schedule,result_id:redash_resultid)
        elsif
          date_now = DateTime.now
          puts '{"Function":"update_all", "Date": "'+date_now.to_s+'", "Status": "Fail - Data Kurang Banyak"}'
        end
        isfinish = 1
        $threadCount = $threadCount - 1
      }
      r.save
    end

    date_now = DateTime.now

    # render json: {
    #   message: "all threshold updated",
		# 	meta: {
		# 		"http_status": 200
		# 	}
    # }.to_json

    puts '{"Function":"update_all", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  def checknewdimension
    cortabot = Cortabot.new()
    cortabot.hawk_loging("check new dimension","SS")
    isfinish = 0
    metrics = Metric.select(:redash_id,:time_column,:value_column,:dimension_column,:time_unit,:telegram_chanel,:value_type,:redash,:email).where("dimension_column != 'NULL'").group("1,2,3,4,5,6,7,8,9")
    metrics.each do |r|
      data = Redash.get_dimension(r.redash_id,r.dimension_column,r.redash)
      alertifnull = 0
      sample = Metric.select("alert_if_null,count(1) as count_alert_if_null").where(["redash_id = ? and time_column = ? and value_column = ? and dimension_column = ? and time_unit = ? and telegram_chanel = ? and value_type = ? and redash = ? and email = ?",r.redash_id,r.time_column,r.value_column,r.dimension_column,r.time_unit,r.telegram_chanel,r.value_type,r.redash,r.email]).group("1").order("count_alert_if_null desc").limit(1)
      sample.each do |x|
        alertifnull = x.alert_if_null
      end

      tagtelegram = ""
      sample = Metric.select("tag_telegram,count(1) as count_tag_telegram").where(["redash_id = ? and time_column = ? and value_column = ? and dimension_column = ? and time_unit = ? and telegram_chanel = ? and value_type = ? and redash = ? and email = ?",r.redash_id,r.time_column,r.value_column,r.dimension_column,r.time_unit,r.telegram_chanel,r.value_type,r.redash,r.email]).group("1").order("count_tag_telegram desc").limit(1)
      sample.each do |x|
        tagtelegram = x.tag_telegram
      end

      microservicecalculation = ""
      sample = Metric.select("microservice_calculation,count(1) as count_microservice_calculation").where(["redash_id = ? and time_column = ? and value_column = ? and dimension_column = ? and time_unit = ? and telegram_chanel = ? and value_type = ? and redash = ? and email = ?",r.redash_id,r.time_column,r.value_column,r.dimension_column,r.time_unit,r.telegram_chanel,r.value_type,r.redash,r.email]).group("1").order("count_microservice_calculation desc").limit(1)
      sample.each do |x|
        microservicecalculation = x.microservice_calculation
      end

      microservicerenderimage = ""
      sample = Metric.select("microservice_render_image,count(1) as count_microservice_render_image").where(["redash_id = ? and time_column = ? and value_column = ? and dimension_column = ? and time_unit = ? and telegram_chanel = ? and value_type = ? and redash = ? and email = ?",r.redash_id,r.time_column,r.value_column,r.dimension_column,r.time_unit,r.telegram_chanel,r.value_type,r.redash,r.email]).group("1").order("count_microservice_render_image desc").limit(1)
      sample.each do |x|
        microservicerenderimage = x.microservice_render_image
      end

      data.each do |d|
        count = Metric.where(["redash_id = ? and time_column = ? and value_column = ? and dimension_column = ? and time_unit = ? and telegram_chanel = ? and value_type = ? and redash = ? and dimension = ? and email = ?",r.redash_id,r.time_column,r.value_column,r.dimension_column,r.time_unit,r.telegram_chanel,r.value_type,r.redash,d[1],r.email])
        if count.length == 0
          INSERT_COUNTER.observe({ service: 'hawk_insert' }, Benchmark.realtime {1})
          newMetric = Metric.new(:redash_id => r.redash_id,:time_column => r.time_column,:value_column => r.value_column,:dimension_column => r.dimension_column,:time_unit => r.time_unit,:telegram_chanel => r.telegram_chanel,:value_type => r.value_type,:redash => r.redash,:dimension => d[1],:on_off => 1,:email => r.email, :alert_if_null => alertifnull, :tag_telegram => tagtelegram, :microservice_calculation => microservicecalculation, :microservice_render_image => microservicerenderimage, :image => "", :on_check => 0)
          newMetric.save
          create_status = true
          if Metric.where(id: r.redash_id).nil?
            create_status = false
          end
          json_res = metric_create_new_dimension(newMetric,r.redash_id,r.time_column,r.value_column,r.time_unit,r.value_type,1,1,r.redash,r.dimension_column,create_status,0,d[1])
        end
      end
    end

    # render json: {
    #   message: "check new dimension ok",
    #   meta: {
    #     "http_status": 200
    #   }
    # }.to_json

    date_now = DateTime.now
    puts '{"Function":"check new dimension", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  # update threshold
  def update_threshold
    cortabot = Cortabot.new()
    cortabot.hawk_loging("update threshold",params[:id])
    # UPDATETHRESHOLD_COUNTER.increment(labels = {}, by = 1)
    UPDATETHRESHOLD_COUNTER.observe({ service: 'hawk_update' }, Benchmark.realtime {1})

    isfinish = 0
    metric = Metric.where(id: params[:id]).first
    Thread.new{
      checkThread()
      $threadCount = $threadCount + 1
      query = metric.redash_id
      time_column = metric.time_column
      value_column = metric.value_column
      time_unit = metric.time_unit
      value_type = metric.value_type
      dimension_column = metric.dimension_column
      dimension = metric.dimension

      if dimension_column != nil && value_type != 3 && value_type != 4
        batas_bawah,batas_atas = Redash.get_csv_dimension(query, time_column, value_column, time_unit, value_type, metric.id, dimension, dimension_column,metric.redash)
      elsif value_type != 3 && value_type != 4
        batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, metric.id,metric.redash)
      else
        batas_atas = metric.upper_threshold
        batas_bawah = metric.lower_threshold
      end

      redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(query,metric.redash)
      redash_schedule = getRedashSchedule(time_unit)
      if time_unit < 4
        redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
      else
        redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 60).second
      end
      if batas_atas != 0 && batas_bawah != 0 || value_type == 3 || value_type == 4
        metric.update(upper_threshold: batas_atas,lower_threshold:batas_bawah,redash_title:redash_title,group:getRedashTitle(redash_title),next_update:redash_update_at,schedule:redash_schedule,result_id:redash_resultid)
        isfinish = 1
      elsif
        date_now = DateTime.now
        puts '{"Function":"update_threshold", "Date": "'+date_now.to_s+'", "Status": "Fail - Data Kurang Banyak"}'
      end
      $threadCount = $threadCount - 1
    }
    metric.save

    render json: {
      message: "update threshold ok",
      meta: {
        "http_status": 200
      }
    }.to_json
    date_now = DateTime.now
    puts '{"Function":"update_threshold", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def self.update_threshold_use_param(id)
    metric = Metric.where(id: id).first
    Thread.new{
      query = metric.redash_id
      time_column = metric.time_column
      value_column = metric.value_column
      time_unit = metric.time_unit
      value_type = metric.value_type
      dimension_column = metric.dimension_column
      dimension = metric.dimension

      if dimension_column != nil && value_type != 3 && value_type != 4
        batas_bawah,batas_atas = Redash.get_csv_dimension(query, time_column, value_column, time_unit, value_type, metric.id, dimension, dimension_column,metric.redash)
      elsif value_type != 3 && value_type != 4
        batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, metric.id,metric.redash)
      else
        batas_atas = metric.upper_threshold
        batas_bawah = metric.lower_threshold
      end

      redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(query,metric.redash)
      redash_schedule = getRedashSchedule(time_unit)
      if time_unit < 4
        redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
      else
        redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 60).second
      end
      if batas_atas != 0 && batas_bawah != 0 || value_type == 3 || value_type == 4
        metric.update(upper_threshold: batas_atas,lower_threshold:batas_bawah,redash_title:redash_title,group:getRedashTitle(redash_title),next_update:redash_update_at,schedule:redash_schedule,result_id:redash_resultid)
      elsif
        date_now = DateTime.now
        puts '{"Function":"update_threshold", "Date": "'+date_now.to_s+'", "Status": "Fail - Data Kurang Banyak"}'
      end
    }
    metric.save

    date_now = DateTime.now
    puts '{"Function":"update_threshold", "Date": "'+date_now.to_s+'", "Id": "'+id.to_s+'", "Status": "ok"}'
  end

  def edit
    metric = Metric.where(id: params[:id]).first
    # render json: metric.to_json

    render json: {
      message: "edit ok",
      data: metric,
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"edit", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def update
    cortabot = Cortabot.new()
    cortabot.hawk_loging("update metric",params[:id])

    metric = Metric.where(id: params[:id]).first

    if metric.value_type != 3 && metric.value_type != 4
      metric.update(resource_params)
    else
      metric.update(resource_params_manual)
    end

    render json: {
      message: "update ok",
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"update", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def delete
    # DELETE_COUNTER.increment(labels = {}, by = 1)
    DELETE_COUNTER.observe({ service: 'hawk_delete' }, Benchmark.realtime {1})
    cortabot = Cortabot.new()
    cortabot.hawk_loging("delete metric",params[:id])

    metric = Metric.where(id: params[:id]).first
    alert = Alert.where(metric_id: params[:id])
    alert.destroy_all
    metric.delete

    render json: {
      message: "delete ok",
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"delete", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def new
    render json: {
      message: "ok",
      meta: {
        "http_status": 200
      }
    }.to_json
  end

  def metric_create_new_dimension(metric,query,time_column,value_column,time_unit,value_type,uthreshold,lthreshold,redash,dimension_column,create_status,isfinish,dimension)
    cortabot = Cortabot.new()
    Thread.new{
      checkThread()
      $threadCount = $threadCount + 1

      if dimension != "null" && value_type != 3 && value_type != 4
        batas_bawah,batas_atas = Redash.get_csv_dimension(query, time_column, value_column, time_unit, value_type, metric.id, dimension, dimension_column, redash)
      elsif value_type != 3 && value_type != 4
        batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, metric.id, redash)
      else
        batas_atas = uthreshold
        batas_bawah = lthreshold
      end

      redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(query,redash)
      redash_schedule = getRedashSchedule(time_unit)
      if time_unit < 4
        redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
      else
        redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 60).second
      end

      if batas_atas != 0 && batas_bawah != 0 || value_type == 3 || value_type == 4
        metric.update(upper_threshold: batas_atas,lower_threshold:batas_bawah,redash_title:redash_title,group:getRedashTitle(redash_title),next_update:redash_update_at,schedule:redash_schedule,result_id:redash_resultid,last_result:0)
        if value_type != 3 && value_type != 4
          if dimension != "null"
            data = Redash.get_outer_threshold_dimension(query,time_column, value_column, time_unit, value_type,batas_bawah,batas_atas, dimension, dimension_column,redash)
          else
            data = Redash.get_outer_threshold(query,time_column, value_column, time_unit, value_type,batas_bawah,batas_atas,redash)
          end
          for i in 0..(data.count - 1)

            alerts = Alert.new
            alerts.value = data[i][0].to_f

            if data[i][0].to_f < batas_bawah
              alerts.is_upper = false
            else
              alerts.is_upper = true
            end

            checkalert = Alert.where(metric_id: metric.id, date: data[i][1])
            checkalert.destroy_all

            alerts.metric_id = metric.id
            alerts.exclude_status = 0
            alerts.date = data[i][1]
            alerts.save
          end
        end
        isfinish = 1
        cortabot.hawk_loging("new dimension","SS")
      elsif
        # FAILED_COUNTER.increment(labels = {}, by = 1)
        FAILED_COUNTER.observe({ service: 'hawk_failed' }, Benchmark.realtime {1})
        date_now = DateTime.now
        puts '{"Function":"create", "Date": "'+date_now.to_s+'", "Status": "Fail - Data Kurang Banyak"}'
        status = 'failed'
        isfinish = 2
        metric.delete
        cortabot.hawk_loging("failed new dimension","SS")
      end
      $threadCount = $threadCount - 1
    }
    if dimension != "null"
      json_res = metric.to_hash
      json_res['response'] = "ok"
      return json_res
    else
      while isfinish == 0
        sleep(1)
      end
      status = 'failed'
      if create_status and response
        status = 'ok'
        date_now = DateTime.now
        puts '{"Function":"create", "Date": "'+date_now.to_s+'", "Status": "ok"}'
      end
      json_res = metric.to_hash

      json_res['response'] = "fail"
      if isfinish == 1
        metric.save
        json_res['response'] = "ok"
      end
      return json_res
    end
  end

  def metric_create(metric,params,create_status,isfinish,dimension)
    Thread.new{
      checkThread()
      $threadCount = $threadCount + 1
      query = params[:metric][:redash_id]
      time_column = params[:metric][:time_column]
      value_column = params[:metric][:value_column]
      time_unit = params[:metric][:time_unit]
      value_type = params[:metric][:value_type]

      if dimension != "null" && value_type != 3 && value_type != 4
        batas_bawah,batas_atas = Redash.get_csv_dimension(query, time_column, value_column, time_unit, value_type, metric.id, dimension, params[:metric][:dimension_column], params[:metric][:redash])
      elsif value_type != 3 && value_type != 4
        batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, metric.id, params[:metric][:redash])
      else
        batas_atas = params[:metric][:upper_threshold]
        batas_bawah = params[:metric][:lower_threshold]
      end

      redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(query,params[:metric][:redash])
      redash_schedule = getRedashSchedule(time_unit)
      if time_unit < 4
        redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
      else
        redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 60).second
      end

      if batas_atas != 0 && batas_bawah != 0 || value_type == 3 || value_type == 4
        metric.update(upper_threshold: batas_atas,lower_threshold:batas_bawah,redash_title:redash_title,group:getRedashTitle(redash_title),next_update:redash_update_at,schedule:redash_schedule,result_id:redash_resultid,last_result:0)
        if value_type != 3 && value_type != 4
          if dimension != "null"
            data = Redash.get_outer_threshold_dimension(query,time_column, value_column, time_unit, value_type,batas_bawah,batas_atas, dimension, params[:metric][:dimension_column],params[:metric][:redash])
          else
            data = Redash.get_outer_threshold(query,time_column, value_column, time_unit, value_type,batas_bawah,batas_atas,params[:metric][:redash])
          end
          for i in 0..(data.count - 1)

            alerts = Alert.new
            alerts.value = data[i][0].to_f

            if data[i][0].to_f < batas_bawah
              alerts.is_upper = false
            else
              alerts.is_upper = true
            end

            checkalert = Alert.where(metric_id: metric.id, date: data[i][1])
            checkalert.destroy_all

            alerts.metric_id = metric.id
            alerts.exclude_status = 0
            alerts.date = data[i][1]
            alerts.save
          end
        end
        isfinish = 1
      elsif
        # FAILED_COUNTER.increment(labels = {}, by = 1)
        FAILED_COUNTER.observe({ service: 'hawk_failed' }, Benchmark.realtime {1})
        date_now = DateTime.now
        puts '{"Function":"create", "Date": "'+date_now.to_s+'", "Status": "Fail - Data Kurang Banyak"}'
        status = 'failed'
        isfinish = 2
        metric.delete
      end
      $threadCount = $threadCount - 1
    }
    if dimension != "null"
      json_res = metric.to_hash
      json_res['response'] = "ok"
      return json_res
    else
      while isfinish == 0
        sleep(1)
      end
      status = 'failed'
      if create_status and response
        status = 'ok'
        date_now = DateTime.now
        puts '{"Function":"create", "Date": "'+date_now.to_s+'", "Status": "ok"}'
      end
      json_res = metric.to_hash

      json_res['response'] = "fail"
      if isfinish == 1
        metric.save
        json_res['response'] = "ok"
      end
      return json_res
    end
  end

  # new metrics
  def create
    cortabot = Cortabot.new()
    cortabot.hawk_loging("add metric",params[:metric][:email])
    isfinish = 0
    if params[:metric][:dimension_column] != ""
      dimensions = Redash.get_dimension(params[:metric][:redash_id],params[:metric][:dimension_column],params[:metric][:redash])
      json_res = []
      for i in 0..(dimensions.count)
          INSERT_COUNTER.observe({ service: 'hawk_insert' }, Benchmark.realtime {1})
          params[:metric][:dimension] = dimensions[i]
          metric = Metric.create(insert_params_dimension)
          create_status = true
          if Metric.where(id: params[:redash_id]).nil?
            create_status = false
          end
          json_res = metric_create(metric,params,create_status,isfinish,dimensions[i])
      end
      json_res['response'] = "ok"

      render json: {
        message: "create status ok",
        data: json_res['response'],
        meta: {
          "http_status": 200
        }
      }.to_json

    else
      INSERT_COUNTER.observe({ service: 'hawk_insert' }, Benchmark.realtime {1})
      metric = Metric.create(insert_params)
      create_status = true
      if Metric.where(id: params[:redash_id]).nil?
        create_status = false
      end
      data = metric_create(metric,params,create_status,isfinish,"null")
      render json: {
        message: "create status "+ data['response'],
        data: data,
        meta: {
          "http_status": 200
        }
      }.to_json

    end
  end

  def resource_params_manual
    params.require(:metric).permit(:id,:redash_title,:redash_id, :time_column, :value_column, :time_unit, :value_type, :email, :result_id, :telegram_chanel, :lower_threshold, :upper_threshold, :redash, :on_off, :alert_if_null, :tag_telegram, :microservice_calculation, :microservice_render_image, :image, :on_check)
  end

  def resource_params
    params.require(:metric).permit(:id,:redash_title,:redash_id, :time_column, :value_column, :time_unit, :value_type, :email, :result_id, :telegram_chanel, :redash, :on_off, :alert_if_null, :tag_telegram, :microservice_calculation, :microservice_render_image, :image, :on_check)
  end

  def insert_params
    params.require(:metric).permit(:redash_title,:redash_id, :time_column, :value_column, :time_unit, :value_type, :email, :result_id, :telegram_chanel, :redash, :on_off, :alert_if_null, :tag_telegram, :microservice_calculation, :microservice_render_image, :image, :on_check)
  end

  def insert_params_dimension
    params.require(:metric).permit(:redash_title,:redash_id, :time_column, :value_column, :time_unit, :value_type, :email, :result_id, :telegram_chanel, :dimension, :dimension_column, :redash, :on_off, :alert_if_null, :tag_telegram, :microservice_calculation, :microservice_render_image, :image, :on_check)
  end

  def checkThread()
    date_now = DateTime.now
    puts '{"Function":"checkThread", "Date": "'+date_now.to_s+'", "Thread Count": "'+$threadCount.to_s+'"}'
    while $threadCount >= $threadLimit
      sleep(1)
    end
  end

  def checkErrorThread()
    # THREAD_COUNTER.set({route: :thread_counter}, $threadCount)
    THREAD_COUNTER.observe({ service: :thread_counter }, Benchmark.realtime { $threadCount })
    date_now = DateTime.now
    puts '{"Function":"checkErrorThread", "Date": "'+date_now.to_s+'", "Error Count": "'+$threadCount.to_s+'"}'
  end

  def removeErrorThread()
    date_now = DateTime.now
    puts '{"Function":"removeErrorThread", "Date": "'+date_now.to_s+'", "Reset Error": "'+$threadCount.to_s+'"}'
    cortabot = Cortabot.new()
    cortabot.hawk_loging("Reset Error ",$threadCount)
    $threadCount = 0
  end

  def get_alert(id)
    metrics = Metric.where(id: id)
    metrics.each do |r|
      Thread.new{
        id = r.id
        query = r.redash_id
        time_column = r.time_column
        value_column = r.value_column
        time_unit = r.time_unit
        upper_threshold = r.upper_threshold
        lower_threshold = r.lower_threshold
        telegram_chanel = r.telegram_chanel || -1001189953846
        redash_t = r.redash_title
        email_to = r.email
        value_type = r.value_type
        dimension_column = r.dimension_column
        dimension = r.dimension
        plast_result = r.last_result
        if dimension_column != nil
          value = Redash.get_result_dimension(query,value_column,time_unit,time_column,value_type,id,dimension_column,dimension,r.redash)
        else
          value = Redash.get_result(query,value_column,time_unit,time_column,value_type,id,r.redash)
          dimension = ""
        end
        # puts value.count
        if value.count == 0
          date_now = DateTime.now
          r.update(last_update:date_now,last_result:3)
          if dimension == "" && r.alert_if_null == 1
            cortabot = Cortabot.new()
            cortabot.send_cortabot_not_found(redash_t,"data not updated, please update your redash",query,telegram_chanel,r.redash)
          end
        else
          for i in 0..(value.count-1)
            value[i][0] = value[i][0].to_f
            if value[i][0] < lower_threshold
              if isNotSend(value[i][0],id,value[i][1])
                # LOWER_THRESHOLD.increment(labels = {}, by = 1)
                LOWER_THRESHOLD.observe({ service: 'hawk_lower_threshold' }, Benchmark.realtime { 1 })
                checkalert = Alert.where(metric_id: id, date: value[i][1])
                checkalert.destroy_all

                alerts = Alert.new
                alerts.value = value[i][0]
                alerts.is_upper = false
                alerts.metric_id = id
                alerts.exclude_status = 0
                alerts.date = value[i][1]
                alerts.save

                cortabot = Cortabot.new()
                redash_title = redash_t
                lowerorupper = "lower"
                lowerorhigher = "lower"

                date_now = DateTime.now
                puts '{"Function":"get_alert", "Date": "'+date_now.to_s+'", "Id": "'+id.to_s+'", "Note": "Lower", "Status": "ok"}'

                redash_link = query
                value_column = value_column
                value_alert = value[i][0]
                upper_threshold = upper_threshold
                lower_threshold = lower_threshold
                telegram_chanel_id = telegram_chanel
                r.update(last_update:date_now,last_result:0)
                if value_type != 3 && value_type != 4
                  cortabot.send_cortabot(redash_title,lowerorupper,value[i][1],redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id,time_unit,lowerorhigher,dimension,r.redash)
                  # SEND_CORTABOT_COUNTER.increment(labels = {}, by = 1)
                  SEND_CORTABOT_COUNTER.observe({ service: 'hawk_send_cortabot' }, Benchmark.realtime { 1 })
                elsif value_type == 4
                  if plast_result != 0
                    cortabot.send_cortabot_single_threshold("ok",redash_title,lowerorupper,value[i][1],redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id,time_unit,lowerorhigher,dimension,r.redash)
                  end
                else
                  cortabot.send_cortabot_manual(redash_title,lowerorupper,value[i][1],redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id,time_unit,lowerorhigher,dimension,r.redash)
                  # SEND_CORTABOT_COUNTER.increment(labels = {}, by = 1)
                  SEND_CORTABOT_COUNTER.observe({ service: 'hawk_send_cortabot' }, Benchmark.realtime { 1 })
                end
              end
              # mail_job = HawkMailer.send_email(redash_title,lowerorupper,date,redash_link,value_column,value_alert,upper_threshold,lower_threshold,email_to)
              # mail_job.deliver_now
            elsif value[i][0] > upper_threshold
              if isNotSend(value[i][0],id,value[i][1])
                # UPPER_THRESHOLD.increment(labels = {}, by = 1)
                UPPER_THRESHOLD.observe({ service: 'hawk_upper_threshold' }, Benchmark.realtime { 1 })
                checkalert = Alert.where(metric_id: id, date: value[i][1])
                checkalert.destroy_all

                alerts = Alert.new
                alerts.value = value[i][0]
                alerts.is_upper = true
                alerts.metric_id = id
                alerts.exclude_status = 0
                alerts.date = value[i][1]
                alerts.save

                cortabot = Cortabot.new()
                redash_title = redash_t
                lowerorupper = "upper"
                lowerorhigher = "higher"

                date_now = DateTime.now
                puts '{"Function":"get_alert", "Date": "'+date_now.to_s+'", "Id": "'+id.to_s+'", "Note": "Upper", "Status": "ok"}'

                redash_link = query
                value_column = value_column
                value_alert = value[i][0]
                upper_threshold = upper_threshold
                lower_threshold = lower_threshold
                telegram_chanel_id = telegram_chanel
                r.update(last_update:date_now,last_result:1)
                if value_type != 3 && value_type != 4
                  cortabot.send_cortabot(redash_title,lowerorupper,value[i][1],redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id,time_unit,lowerorhigher,dimension,r.redash)
                  # SEND_CORTABOT_COUNTER.increment(labels = {}, by = 1)
                  SEND_CORTABOT_COUNTER.observe({ service: 'hawk_send_cortabot' }, Benchmark.realtime {1})
                elsif value_type == 4
                  if plast_result != 1
                    cortabot.send_cortabot_single_threshold("warning",redash_title,lowerorupper,value[i][1],redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id,time_unit,lowerorhigher,dimension,r.redash)
                  end
                else
                  cortabot.send_cortabot_manual(redash_title,lowerorupper,value[i][1],redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id,time_unit,lowerorhigher,dimension,r.redash)
                  # SEND_CORTABOT_COUNTER.increment(labels = {}, by = 1)
                  SEND_CORTABOT_COUNTER.observe({ service: 'hawk_send_cortabot' }, Benchmark.realtime {1})
                end
              end
              # mail_job = HawkMailer.send_email(redash_title,lowerorupper,date,redash_link,value_column,value_alert,upper_threshold,lower_threshold,email_to)
              # mail_job.deliver_now
            else
              # puts value[i][0]
              # DIDALAM_THRESHOLD.increment(labels = {}, by = 1)
              DIDALAM_THRESHOLD.observe({ service: 'hawk_inner_threshold' }, Benchmark.realtime { 1 })
              date_now = DateTime.now
              r.update(last_update:date_now,last_result:2)
              puts '{"Function":"get_alert", "Date": "'+date_now.to_s+'", "Id": "'+id.to_s+'", "Note": "Didalam threshold", "Status": "ok"}'
            end
          end
        end
      }
      r.save
    end
  end

  def checkMetric
    date_current = DateTime.current
    metrics = Metric.where("on_check = 0 and on_off = 1")
    metrics.each do |metric|
      if date_current.to_s[0..16] == (metric.next_update).to_s[0..16]
        checkThread()
        $threadCount = $threadCount + 1
        Thread.new{
          metric.update(on_check:1)
          if (metric.result_id).to_s == (Redash.get_redash_result_id(metric.redash_id,metric.redash)).to_s
            result_redash_id = Redash.refresh(metric.redash_id,metric.redash)
          end
          redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(metric.redash_id,metric.redash)
          redash_schedule = getRedashSchedule(metric.time_unit)
          if metric.time_unit < 4
            redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
          else
            redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 60).second
          end
          metric.update(redash_title:redash_title,group:getRedashTitle(redash_title),next_update:redash_update_at,schedule:redash_schedule,result_id:redash_resultid)
          get_alert(metric.id)
          $threadCount = $threadCount - 1
          metric.update(on_check:0)
        }
      end
    end
  end

  def getRedashSchedule(time_unit)
    if time_unit == 0
      return 3600
    elsif time_unit == 1
      return 3600*24
    elsif time_unit == 2
      return 3600*24*7
    elsif time_unit == 3
      return 3600*24*7*4
    elsif time_unit == 4
      return 3600/12
    elsif time_unit == 5
      return 3600/6
    elsif time_unit == 6
      return 3600/4
    elsif time_unit == 7
      return 3600/2
    elsif time_unit == 8
      return 3600/60
    end
  end

  def getRedashTitle(redash_title)
    redash_title = redash_title.to_s
    str_len = redash_title.length

    if (redash_title.split("]")[0]).length != str_len
      title = (redash_title.split("]")[0]).split("[")[1]
    elsif (redash_title.split("_")[0]).length != str_len
      title = redash_title.split("_")[0]
    elsif (redash_title.split("-")[0]).length != str_len
      title = redash_title.split("-")[0]
    else
      title = redash_title
    end
    title = title.strip
    title = title.downcase
    return title
  end

  def isNotSend(value,metric_id,date)
    key = value.to_s << "|" << metric_id.to_s << "|" << date.to_s

    if ($redis.get(key)).nil?
      $redis.set(key,key)
      $redis.expire(key,2.minute.to_i)
      return true
    else
      return false
    end
    # return true
  end

  def checkDeadSchedule()
    date_now = DateTime.current - 10.minutes
    metrics = Metric.where(["next_update < '%s' and on_off = 1",date_now])
    metrics.each do |r|
      next_update = DateTime.parse((DateTime.current).to_s) + 300.second
      r.update(next_update:next_update)
    end
  end

  def on_off
    cortabot = Cortabot.new()

    metric = Metric.where(id: params[:id]).first
    if metric.on_off == 1
      cortabot.hawk_loging("set off",params[:id])
      metric.update(on_off:0)
    else
      cortabot.hawk_loging("set on",params[:id])
      metric.update(on_off:1)
    end
    # render json: metric.to_json
    render json: {
      message: "on off status ok",
      data: metric,
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"set on off", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def alert_null_data
    cortabot = Cortabot.new()

    metric = Metric.where(id: params[:id]).first
    if metric.alert_if_null == 1
      cortabot.hawk_loging("alert if null off",params[:id])
      metric.update(alert_if_null:0)
    else
      cortabot.hawk_loging("alert if null on",params[:id])
      metric.update(alert_if_null:1)
    end
    # render json: metric.to_json
    render json: {
      message: "alert if null status ok",
      data: metric,
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"set alert if null", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def runinfiveminutes
    cortabot = Cortabot.new()
    cortabot.hawk_loging("run in 5 minute",params[:id])
    metric = Metric.where(id: params[:id]).first
    date_now = DateTime.current
    metric.update(next_update:date_now + 5.minutes)
    render json: {
      message: "run in five minute status ok",
      data: metric,
      meta: {
        "http_status": 200
      }
    }.to_json

    date_now = DateTime.now
    puts '{"Function":"run in five minute", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def testroute
    puts "hahahehehoho"
  end

end
