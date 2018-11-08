require 'httparty'
require 'dotenv'
require 'date'

class Cortabot
  def send_cortabot(redash_title,status_uol,time_schedule,redash_link,value_column,value_alert,upper_threshold,lower_threshold,id,time_unit,lowerorhigher,dimension)
    title = redash_title.to_s
    source = "https://redash.bukalapak.io/queries/"<<redash_link.to_s

    increase,value_increase = HawkMain.hitungIncrease(value_alert)
    if status_uol.to_s == "lower"
      ratio_relative = (((value_alert/lower_threshold)) * 100).round(2)
      thresholdd = ((HawkMain.hitungInvers(lower_threshold).abs)*100).round(2)
    else
      ratio_relative = (((value_alert/upper_threshold)) * 100).round(2)
      thresholdd = ((HawkMain.hitungInvers(upper_threshold).abs)*100).round(2)
    end

    message_dimension =  ""
    if dimension != ""
      message_dimension =  " on dimension <code>"<<dimension<<"</code> "
    end

    if time_unit == 0
      # time_schedule = (time_schedule).to_s[0..9]<<" "<<(time_schedule).to_s[11..18]
      time_schedule = indo_time(time_schedule.to_s)
      message = "<code>"<<value_column.to_s<<"</code> "<<message_dimension<<" is <b>"<<lowerorhigher.to_s<<"</b> than threshold. "<<"The <b>"<<status_uol.to_s<<"</b> threshold is <code>"<<thresholdd.to_s[0..6]<<"%</code>."<<" Current value <code>"<<increase.to_s<<" "<<(value_increase.round(2)).to_s[0..6]<<"% </code> from 7 days ago and <code>"<<ratio_relative.to_s[0..6]<<"%</code> relative to the <b>"<<status_uol.to_s<<"</b> threshold."
    elsif time_unit == 1
      message = "<code>"<<value_column.to_s<<"</code> "<<message_dimension<<" is <b>"<<lowerorhigher.to_s<<"</b> than threshold. "<<"The <b>"<<status_uol.to_s<<"</b> threshold is <code>"<<thresholdd.to_s[0..6]<<"%</code>."<<" Current value <code>"<<increase.to_s<<" "<<(value_increase.round(2)).to_s[0..6]<<"% </code> from 28 days ago and <code>"<<ratio_relative.to_s[0..6]<<"%</code> relative to the <b>"<<status_uol.to_s<<"</b> threshold."
    elsif time_unit == 2
      message = "<code>"<<value_column.to_s<<"</code> "<<message_dimension<<" is <b>"<<lowerorhigher.to_s<<"</b> than threshold. "<<"The <b>"<<status_uol.to_s<<"</b> threshold is <code>"<<thresholdd.to_s[0..6]<<"%</code>."<<" Current value <code>"<<increase.to_s<<" "<<(value_increase.round(2)).to_s[0..6]<<"% </code> from 4 weeks ago and <code>"<<ratio_relative.to_s[0..6]<<"%</code> relative to the <b>"<<status_uol.to_s<<"</b> threshold."
    end

    if dimension != ""
      url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?title='<<title.titleize<<"&dimension=<code>"<<dimension.to_s<<"</code>&time="<<time_schedule.to_s<<'&message='<<message.to_s<<'&source='<<source<<'&id='<<id.to_s<<'&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]
    else
      url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?title='<<title.titleize<<"&time="<<time_schedule.to_s<<'&message='<<message.to_s<<'&source='<<source<<'&id='<<id.to_s<<'&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]
    end
    puts '{"Function":"send_cortabot", "Date": "'+time_schedule.to_s+'", "To": "'+id.to_s+'", "Status": "ok"}'
    HTTParty.get(URI.encode(url))
  end

  def send_cortabot_manual(redash_title,status_uol,time_schedule,redash_link,value_column,value_alert,upper_threshold,lower_threshold,id,time_unit,lowerorhigher,dimension)
    title = redash_title.to_s
    source = "https://redash.bukalapak.io/queries/"<<redash_link.to_s

    if status_uol.to_s == "lower"
      thresholdd = lower_threshold
    else
      thresholdd = upper_threshold
    end

    message_dimension =  ""
    if dimension != ""
      message_dimension =  " on dimension <code>"<<dimension<<"</code> "
    end

    if time_unit == 0
      # time_schedule = (time_schedule).to_s[0..9]<<" "<<(time_schedule).to_s[11..18]
      time_schedule = indo_time(time_schedule.to_s)
    end
    message = "<code>"<<value_column.to_s<<"</code> "<<message_dimension<<" is <b>"<<lowerorhigher.to_s<<"</b> than threshold. "<<"The <b>"<<status_uol.to_s<<"</b> threshold is <code>"<<thresholdd.to_s[0..6]<<"</code>."<<" Current value is <code>"<<value_alert.to_s<<"</code>"

    if dimension != ""
      url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?title='<<title.titleize<<"&dimension=<code>"<<dimension.to_s<<"</code>&time="<<time_schedule.to_s<<'&message='<<message.to_s<<'&source='<<source<<'&id='<<id.to_s<<'&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]
    else
      url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?title='<<title.titleize<<"&time="<<time_schedule.to_s<<'&message='<<message.to_s<<'&source='<<source<<'&id='<<id.to_s<<'&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]
    end
    puts '{"Function":"send_cortabot_manual", "Date": "'+time_schedule.to_s+'", "To": "'+id.to_s+'", "Status": "ok"}'
    HTTParty.get(URI.encode(url))
  end

  def test_cortabot(id)
    url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?message=Test_Message'<<'&id='<<id.to_s<<'&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]
    puts url
    date_now = DateTime.current
    puts '{"Function":"send_cortabot_test", "Date": "'+date_now.to_s+'", "To": "'+id.to_s+'", "Status": "ok"}'
    HTTParty.get(URI.encode(url))
  end

  def hawk_loging(action,note)
    url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?message=Loging&action='<<action.to_s<<'&note='<<note.to_s<<'&id=-279091412&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]
    puts url
    date_now = DateTime.current
    puts '{"Function":"send_cortabot_loging", "Date": "'+date_now.to_s+'", "To": "-279091412", "Status": "ok"}'
    HTTParty.get(URI.encode(url))
  end

  def indo_time(time)
    time_schedule = time.split('+')[0]
    if time.split('+')[1] != nil
      timezone = ((time.split('+')[1]).split(':')[0]).to_f
      time_schedule = DateTime.parse time_schedule
      time_schedule = time_schedule - timezone.hours
    end
    time_schedule = (time_schedule).to_s[0..9]<<" "<<(time_schedule).to_s[11..18]
    return time_schedule
  end
end
