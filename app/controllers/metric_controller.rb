require 'dotenv'
require 'telegram/bot'
require 'date'

class MetricController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create, :update_all, :update_threshold, :update, :delete, :update_all, :confirmuser]
  $threadCount = 0
  $threadLimit = ENV["THREAD_LIMIT"].to_f

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
        if batas_atas != 0 && batas_bawah != 0
          r.update(upper_threshold: batas_atas,lower_threshold:batas_bawah)
        elsif
          puts "warning : data kurang banyak"
        end
        $threadCount = $threadCount - 1
      }
      r.save
    end
  end

  # update threshold
  def update_threshold
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
      redash_title = Redash.get_redash_title(query)
      if batas_atas != 0 && batas_bawah != 0
        metric.update(upper_threshold: batas_atas,lower_threshold:batas_bawah,redash_title:redash_title)
      elsif
        puts "warning : data kurang banyak"
      end
      $threadCount = $threadCount - 1
    }
    metric.save
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
    metric = Metric.where(id: params[:id]).first
    alert = Alert.where(metric_id: params[:id])
    alert.destroy_all
    metric.delete
  end

  def new

  end

  # new metrics
  def create
    metric = Metric.create(resource_params)
    create_status = true
    if Metric.where(redash_id: params[:redash_id]).nil?
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
      # batas_bawah,batas_atas = Redash.set_threshold(query, time_column, value_column, time_unit, value_type, metric.id)
      # batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, metric.id)
      batas_bawah,batas_atas = Redash.get_csv(query, time_column, value_column, time_unit, value_type, metric.id)
      redash_title = Redash.get_redash_title(query)
      if batas_atas != 0 && batas_bawah != 0
        metric.update(result_id: 0, upper_threshold: batas_atas,lower_threshold:batas_bawah,redash_title:redash_title)
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

      elsif
        puts "warning : data kurang banyak"
      end
      $threadCount = $threadCount - 1
    }
    status = 'failed'
    if create_status and response
      status = 'ok'
    end
    json_res = metric.to_hash
    json_res['response'] = status

    metric.save
    render json: json_res
  end

  def resource_params
    params.require(:metric).permit(:redash_id, :time_column, :value_column, :time_unit, :value_type, :email, :result_id, :telegram_chanel)

  end

  def checkThread()
    while $threadCount > $threadLimit
      sleep(1)
    end
  end

  def checkErrorThread()
    puts "-E-r-r-o-r- -C-o-u-n-t- : "<<$threadCount.to_s
    while $threadCount > $threadLimit
      sleep(1)
    end
  end

  def get_alert(time)
    metrics = Metric.where(time_unit: time)
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
        telegram_chanel = r.telegram_chanel || 557559054
        redash_t = r.redash_title
        email_to = r.email
        value_type = r.value_type
        value = Redash.get_result(query,value_column,time_unit,time_column,value_type,id)
        for i in 0..(value.count-1)
          if value[i][0] < lower_threshold
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
            date = DateTime.current
            redash_link = query
            value_column = value_column
            value_alert = value[i][0]
            upper_threshold = upper_threshold
            lower_threshold = lower_threshold
            telegram_chanel_id = telegram_chanel
            cortabot.send_cortabot(redash_title,lowerorupper,date,redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id)

            mail_job = HawkMailer.send_email(redash_title,lowerorupper,date,redash_link,value_column,value_alert,upper_threshold,lower_threshold,email_to)
            mail_job.deliver_now
            # send_tele('lower',query,value[i][0])
          elsif value[i][0] > upper_threshold
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
            date = DateTime.current
            redash_link = query
            value_column = value_column
            value_alert = value[i][0]
            upper_threshold = upper_threshold
            lower_threshold = lower_threshold
            telegram_chanel_id = telegram_chanel
            cortabot.send_cortabot(redash_title,lowerorupper,date,redash_link,value_column,value_alert,upper_threshold,lower_threshold,telegram_chanel_id)

            mail_job = HawkMailer.send_email(redash_title,lowerorupper,date,redash_link,value_column,value_alert,upper_threshold,lower_threshold,email_to)
            mail_job.deliver_now
            # send_tele('upper',query,value[i][0])
          else
            puts value[i][0]
            puts "didalam threshold"
          end
        end
        $threadCount = $threadCount - 1
      }
      r.save
    end
  end

  def send_tele(status,query,value)
    token = ENV["TOKEN_TELEGRAM_HAWKBOT"]
    api = ::Telegram::Bot::Api.new(token)
    date_now = DateTime.current
    api.call('sendMessage', chat_id: ENV["TELEGRAM_GROUP1"], text: "#{status} - Alert redash id #{query} - #{date_now} : Value : #{value}")
  end

end
