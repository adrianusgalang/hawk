require 'date'
require 'dotenv'

class HawkMailer < ApplicationMailer
  def send_email(redash_title,status_uol,time_schedule,redash_link,value_column,value_alert,upper_threshold,lower_threshold,email)
    title = redash_title.to_s<<" alert "<<status_uol.to_s
    source = "https://redash.bukalapak.io/queries/"<<redash_link.to_s
    message = value_column.to_s<<" on "<<redash_title.to_s<<" has reached "<<value_alert.to_s<<" while the threshold is between "<<upper_threshold.to_s<<" and "<<lower_threshold.to_s

    mail(to: email, subject: "#{title} #{time_schedule}", body: "#{message} . Source : #{source}")

    date_now = DateTime.current
    puts '{"Function":"send_email", "Date": "'+date_now.to_s+'","To": "'+email.to_s+'", "Status": "ok"}'
  end
end
