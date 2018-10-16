require 'httparty'
require 'dotenv'
require 'date'

class Cortabot
  def send_cortabot(redash_title,status_uol,time_schedule,redash_link,value_column,value_alert,upper_threshold,lower_threshold,id,time_unit,lowerorhigher)
    title = redash_title.to_s
    source = "https://redash.bukalapak.io/queries/"<<redash_link.to_s
    message = value_column.to_s<<" on "<<redash_title.to_s<<" is "<<lowerorhigher.to_s<<" than "<<status_uol.to_s<<" threshold. Please check the data."
    increase,value_increase = HawkMain.hitungIncrease(value_alert)
    if time_unit == 0
      time_schedule = (time_schedule).to_s[0..9]<<" "<<(time_schedule).to_s[11..18]
      note = "Current value "<<increase.to_s<<" "<<value_increase.to_s[0..6]<<"% from 7 days ago"
    elsif time_unit == 1
      note = "Current value "<<increase.to_s<<" "<<value_increase.to_s[0..6]<<"% from 28 days ago"
    elsif time_unit == 2
      note = "Current value "<<increase.to_s<<" "<<value_increase.to_s[0..6]<<"% from 4 weeks ago"
    end
    url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbpx?title='<<title.titleize<<"&time="<<time_schedule.to_s<<'&source='<<source<<'&message='<<message.capitalize<<'&note='<<note.to_s<<'&id='<<id.to_s<<'&token='<<ENV["TOKEN_TELEGRAM_HAWKBOT"]

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
