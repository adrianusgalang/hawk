require 'httparty'
require 'dotenv'
require 'date'

class Cortabot
  def send_cortabot(redash_title,status_uol,time_schedule,redash_link,value_column,value_alert,upper_threshold,lower_threshold,id,time_unit)
    title = redash_title.to_s<<" alert "<<status_uol.to_s
    source = "https://redash.bukalapak.io/queries/"<<redash_link.to_s
    message = value_column.to_s<<" on "<<redash_title.to_s<<" is "<<status_uol.to_s<<" than threshold. Please check the data."
    increase,value_increase = HawkMain.hitungIncrease(value_alert)
    if time_unit == 0
      note = "Current value is "<<increase.to_s<<" "<<value_increase.to_s<<"% from 7 days ago"
    else
      note = "Current value is "<<increase.to_s<<" "<<value_increase.to_s<<"% from 28 days ago"
    end
    url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?title='<<title.titleize<<" "<<time_schedule.to_s<<'&source='<<source<<'&message='<<message.capitalize<<'&note='<<note.to_s<<'&id='<<id.to_s<<'&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]

    date_now = DateTime.current
    puts '{"Function":"send_cortabot", "Date": "'+date_now.to_s+'", "To": "'+id.to_s+'", "Status": "ok"}'
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
