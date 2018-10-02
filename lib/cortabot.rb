require 'httparty'
require 'dotenv'
require 'date'

class Cortabot
  def send_cortabot(redash_title,status_uol,time_schedule,redash_link,value_column,value_alert,upper_threshold,lower_threshold,id)
    title = redash_title.to_s<<" alert "<<status_uol.to_s
    source = "https://redash.bukalapak.io/queries/"<<redash_link.to_s
    message = value_column.to_s<<" on "<<redash_title.to_s<<" has reached "<<value_alert.to_s<<" while the threshold is between "<<upper_threshold.to_s<<" and "<<lower_threshold.to_s
    url = 'http://'<<ENV["TELE_URL"]<<':'<<ENV["TELE_PORT"]<<'/cdbp?title='<<title.titleize<<" "<<time_schedule.to_s<<'&source='<<source<<'&message='<<message.capitalize<<'&id='<<id.to_s
    if url.include? '_'
       url.sub!('_', ' ')
    end

    date_now = DateTime.current
    puts '{"Function":"send_cortabot", "Date": "'+date_now.to_s+'", "To": "'+id.to_s+'", "Status": "ok"}'    
    # puts "-s-e-n-d- -t-o- -t-e-l-e-g-r-a-m- -u-s-e- -c-o-r-t-a-b-o-t-"
    # puts URI.encode(url)
    HTTParty.get(URI.encode(url))
    # puts response
  end
end
