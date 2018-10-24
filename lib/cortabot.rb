require 'httparty'
require 'dotenv'
require 'date'

class Cortabot
  def send_cortabot(redash_title,status_uol,time_schedule,redash_link,value_column,value_alert,upper_threshold,lower_threshold,id,time_unit,lowerorhigher)
    title = redash_title.to_s
    source = "https://redash.bukalapak.io/queries/"<<redash_link.to_s

    # message = "<code>"<<value_column.to_s<<"</code> is <b>"<<lowerorhigher.to_s<<"</b> than threshold.\n\n"<<"The "<<status_uol.to_s<<" threshold is "<<value_alert.to_s<<".\n"<<"The current value "<<increase.to_s<<" "<<value_increase.to_s[0..6]<<"% from CC days ago and DD times relative to the threshold."
    # if status_uol.to_s == "lower"
    #   message = "<code>"<<value_column.to_s<<"</code> is <b>"<<lowerorhigher.to_s<<"</b> than threshold.\n\n"<<"The "<<status_uol.to_s<<" threshold is "<<value_alert.to_s<<".\n"<<"The current value increase/decrease BB% from CC days ago and DD times relative to the threshold."
    # else
    #   message = "<code>"<<value_column.to_s<<"</code> on <code>"<<redash_title.to_s<<"</code> is <b>"<<lowerorhigher.to_s<<"</b> <code>"<<HawkMain.hitungInvers(value_alert).to_s[0..6]<<"</code> than <b>"<<status_uol.to_s<<"</b> threshold <code>"<<HawkMain.hitungInvers(upper_threshold).to_s[0..6]<<"</code>. "
    # end

    increase,value_increase = HawkMain.hitungIncrease(value_alert)
    if status_uol.to_s == "lower"
      puts value_alert
      puts lower_threshold
      ratio_relative = (((value_alert/lower_threshold)) * 100).round(2)
      thresholdd = ((HawkMain.hitungInvers(lower_threshold).abs)*100).round(2)
    else
      puts value_alert
      puts lower_threshold
      ratio_relative = (((value_alert/upper_threshold)) * 100).round(2)
      thresholdd = ((HawkMain.hitungInvers(upper_threshold).abs)*100).round(2)
    end

    if time_unit == 0
      time_schedule = (time_schedule).to_s[0..9]<<" "<<(time_schedule).to_s[11..18]
      message = "<code>"<<value_column.to_s<<"</code> is <b>"<<lowerorhigher.to_s<<"</b> than threshold. "<<"The <b>"<<status_uol.to_s<<"</b> threshold is <code>"<<thresholdd.to_s[0..6]<<"%</code>."<<" Current value <code>"<<increase.to_s<<" "<<(value_increase.round(2)).to_s[0..6]<<"% </code> from 7 days ago and <code>"<<ratio_relative.to_s[0..6]<<"%</code> relative to the <b>"<<status_uol.to_s<<"</b> threshold."
    elsif time_unit == 1
      message = "<code>"<<value_column.to_s<<"</code> is <b>"<<lowerorhigher.to_s<<"</b> than threshold. "<<"The <b>"<<status_uol.to_s<<"</b> threshold is <code>"<<thresholdd.to_s[0..6]<<"%</code>."<<" Current value <code>"<<increase.to_s<<" "<<(value_increase.round(2)).to_s[0..6]<<"% </code> from 28 days ago and <code>"<<ratio_relative.to_s[0..6]<<"%</code> relative to the <b>"<<status_uol.to_s<<"</b> threshold."
    elsif time_unit == 2
      message = "<code>"<<value_column.to_s<<"</code> is <b>"<<lowerorhigher.to_s<<"</b> than threshold. "<<"The <b>"<<status_uol.to_s<<"</b> threshold is <code>"<<thresholdd.to_s[0..6]<<"%</code>."<<" Current value <code>"<<increase.to_s<<" "<<(value_increase.round(2)).to_s[0..6]<<"% </code> from 4 weeks ago and <code>"<<ratio_relative.to_s[0..6]<<"%</code> relative to the <b>"<<status_uol.to_s<<"</b> threshold."
    end

    url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?title='<<title.titleize<<"&time="<<time_schedule.to_s<<'&message='<<message.to_s<<'&source='<<source<<'&id='<<id.to_s<<'&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]
    puts "-----------------------------"
    puts url
    puts "-----------------------------"
    puts '{"Function":"send_cortabot", "Date": "'+time_schedule.to_s+'", "To": "'+id.to_s+'", "Status": "ok"}'
    HTTParty.get(URI.encode(url))
  end

  def test_cortabot(id)
    url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?message=Test_Message'<<'&id='<<id.to_s<<'&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]
    puts url
    date_now = DateTime.current
    puts '{"Function":"send_cortabot", "Date": "'+date_now.to_s+'", "To": "'+id.to_s+'", "Status": "ok"}'
    HTTParty.get(URI.encode(url))
  end
end
