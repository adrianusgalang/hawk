require 'date'
require 'dotenv'

class HawkMailer < ApplicationMailer
  def send_email(query,value,status)
    date_now = DateTime.current
    mail(to: ENV["EMAIL_FROM"], subject: "#{status} - Alert redash id #{query} - #{date_now}", body: "Value : #{value}")
  end
end
