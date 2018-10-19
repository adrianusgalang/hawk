require 'dotenv'
require 'telegram/bot'
require 'date'

class MetricController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create, :update_all, :update_threshold, :update, :delete, :update_all, :confirmuser]
  $threadCount = 0
  $threadLimit = ENV["THREAD_LIMIT"].to_f

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
    date_now = DateTime.now
    puts '{"Function":"manage", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  def update_all
    isfinish = 0
    metrics = Metric.all
    metrics.each do |r|
      checkThread()
      $threadCount = $threadCount + 1
      Thread.new{
        query = r.redash_id
        time_column = r.time_column
        value_column = r.value_column
        time_unit = r.time_unit
        value_type = r.value_type
        batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, r.id)
        redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(query)
        redash_schedule = getRedashSchedule(time_unit)
        redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
        if batas_atas != 0 && batas_bawah != 0
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
    while isfinish == 0
      sleep(1)
    end
    date_now = DateTime.now
    puts '{"Function":"update_all", "Date": "'+date_now.to_s+'", "Status": "ok"}'
  end

  # update threshold
  def update_threshold
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
      # result_id,batas_bawah,batas_atas = Redash.set_threshold(query, time_column, value_column, time_unit, value_type)
      batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, metric.id)
      redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(query)
      redash_schedule = getRedashSchedule(time_unit)
      redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
      if batas_atas != 0 && batas_bawah != 0
        metric.update(upper_threshold: batas_atas,lower_threshold:batas_bawah,redash_title:redash_title,group:getRedashTitle(redash_title),next_update:redash_update_at,schedule:redash_schedule,result_id:redash_resultid)
        isfinish = 1
      elsif
        date_now = DateTime.now
        puts '{"Function":"update_threshold", "Date": "'+date_now.to_s+'", "Status": "Fail - Data Kurang Banyak"}'
      end
      $threadCount = $threadCount - 1
    }
    metric.save
    while isfinish == 0
      sleep(1)
    end
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
      # result_id,batas_bawah,batas_atas = Redash.set_threshold(query, time_column, value_column, time_unit, value_type)
      batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, metric.id)
      redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(query)
      redash_schedule = getRedashSchedule(time_unit)
      redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
      if batas_atas != 0 && batas_bawah != 0
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
    render json: metric.to_json

    date_now = DateTime.now
    puts '{"Function":"edit", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def update
    metric = Metric.where(id: params[:id]).first
    metric.update(resource_params)

    date_now = DateTime.now
    puts '{"Function":"update", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def delete
    metric = Metric.where(id: params[:id]).first
    alert = Alert.where(metric_id: params[:id])
    alert.destroy_all
    metric.delete

    date_now = DateTime.now
    puts '{"Function":"delete", "Date": "'+date_now.to_s+'", "Id": "'+params[:id].to_s+'", "Status": "ok"}'
  end

  def new

  end

  # new metrics
  def create
    isfinish = 0
    metric = Metric.create(insert_params)
    create_status = true
    if Metric.where(id: params[:redash_id]).nil?
      create_status = false
    end
    Thread.new{
      checkThread()
      $threadCount = $threadCount + 1
      query = params[:metric][:redash_id]
      time_column = params[:metric][:time_column]
      value_column = params[:metric][:value_column]
      time_unit = params[:metric][:time_unit]
      value_type = params[:metric][:value_type]
      batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, metric.id)
      redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(query)
      redash_schedule = getRedashSchedule(time_unit)
      redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
      if batas_atas != 0 && batas_bawah != 0
        metric.update(upper_threshold: batas_atas,lower_threshold:batas_bawah,redash_title:redash_title,group:getRedashTitle(redash_title),next_update:redash_update_at,schedule:redash_schedule,result_id:redash_resultid)
        data = Redash.get_outer_threshold(query,time_column, value_column, time_unit, value_type,batas_bawah,batas_atas)

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
        isfinish = 1
      elsif
        date_now = DateTime.now
        puts '{"Function":"create", "Date": "'+date_now.to_s+'", "Status": "Fail - Data Kurang Banyak"}'
        status = 'failed'
        isfinish = 2
      end
      $threadCount = $threadCount - 1
    }
    status = 'failed'
    if create_status and response
      status = 'ok'
      date_now = DateTime.now
      puts '{"Function":"create", "Date": "'+date_now.to_s+'", "Status": "ok"}'
    end
    json_res = metric.to_hash

    while isfinish == 0
      sleep(1)
    end
    if isfinish == 1
      metric.save
      json_res['response'] = "ok"
    end
    if isfinish == 2
      metric.delete
      json_res['response'] = "fail"
    end
    render json: json_res
  end

  def resource_params
    params.require(:metric).permit(:id,:redash_title,:redash_id, :time_column, :value_column, :time_unit, :value_type, :email, :result_id, :telegram_chanel)
  end

  def insert_params
    params.require(:metric).permit(:redash_title,:redash_id, :time_column, :value_column, :time_unit, :value_type, :email, :result_id, :telegram_chanel)
  end

  def checkThread()
    date_now = DateTime.now
    puts '{"Function":"checkThread", "Date": "'+date_now.to_s+'", "Thread Count": "'+$threadCount.to_s+'"}'
    while $threadCount >= $threadLimit
      sleep(1)
    end
  end

  def checkErrorThread()
    date_now = DateTime.now
    puts '{"Function":"checkErrorThread", "Date": "'+date_now.to_s+'", "Error Count": "'+$threadCount.to_s+'"}'
  end

  def removeErrorThread()
    date_now = DateTime.now
    puts '{"Function":"removeErrorThread", "Date": "'+date_now.to_s+'", "Reset Error": "'+$threadCount.to_s+'"}'
    $threadCount = 0
  end

  def get_alert(id)
    metrics = Metric.where(id: id)
    metrics.each do |r|
      checkThread()
      $threadCount = $threadCount + 1
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
        value = Redash.get_result(query,value_column,time_unit,time_column,value_type,id)
        for i in 0..(value.count-1)
          if value[i][0] < lower_threshold
            if isNotSend(value[i][0],id,value[i][1])
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
              cortabot.send_cortabot(redash_title,lowerorupper,value[i][1],redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id,time_unit,lowerorhigher)
            end
            # mail_job = HawkMailer.send_email(redash_title,lowerorupper,date,redash_link,value_column,value_alert,upper_threshold,lower_threshold,email_to)
            # mail_job.deliver_now
          elsif value[i][0] > upper_threshold
            if isNotSend(value[i][0],id,value[i][1])
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
              cortabot.send_cortabot(redash_title,lowerorupper,value[i][1],redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id,time_unit,lowerorhigher)
            end
            # mail_job = HawkMailer.send_email(redash_title,lowerorupper,date,redash_link,value_column,value_alert,upper_threshold,lower_threshold,email_to)
            # mail_job.deliver_now
          else
            # puts value[i][0]
            date_now = DateTime.now
            puts '{"Function":"get_alert", "Date": "'+date_now.to_s+'", "Id": "'+id.to_s+'", "Note": "Didalam threshold", "Status": "ok"}'
          end
        end
        $threadCount = $threadCount - 1
      }
      r.save
    end
  end

  def checkMetric
    date_current = DateTime.current
    metrics = Metric.all
    metrics.each do |metric|
      if date_current.to_s[0..16] == (metric.next_update).to_s[0..16]
        checkThread()
        $threadCount = $threadCount + 1
        Thread.new{
          if (metric.result_id).to_s == (Redash.get_redash_result_id(metric.redash_id)).to_s
            result_redash_id = Redash.refresh(metric.redash_id)
          end
          redash_title,redash_resultid,redash_update_at = Redash.get_redash_detail(metric.redash_id)
          redash_schedule = getRedashSchedule(metric.time_unit)
          redash_update_at = DateTime.parse(redash_update_at) + (redash_schedule.to_f + 300).second
          metric.update(redash_title:redash_title,group:getRedashTitle(redash_title),next_update:redash_update_at,schedule:redash_schedule,result_id:redash_resultid)
          get_alert(metric.id)
          $threadCount = $threadCount - 1
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
    end
  end

  def getRedashTitle(redash_title)
    redash_title = redash_title.to_s
    str_len = redash_title.length

    if (redash_title.split("_")[0]).length != str_len
      title = redash_title.split("_")[0]
    elsif (redash_title.split("-")[0]).length != str_len
      title = redash_title.split("-")[0]
    elsif (redash_title.split("]")[0]).length != str_len
      title = (redash_title.split("]")[0]).split("[")[1]
    else
      title = redash_title
    end
    title = title.strip
    title = title.downcase
    return title
  end

  def isNotSend(value,metric_id,date)
    metric = Metric.where(id: metric_id).first
    key = value.to_s<<"|"<<metric_id.to_s<<"|"<<date.to_s
    sleep(rand(0..60))
    if metric.key == key
      return false
    else
      metric.update(key: key)
      return true
    end
  end

end
