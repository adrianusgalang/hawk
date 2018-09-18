# Load the Rails application.
require_relative 'application'
require 'dotenv'
# Initialize the Rails application.

Rails.application.initialize! do
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address:              ENV["SMTP_ADDRESS"],
    port:                 ENV["SMTP_PORT"],
    domain:               ENV["SMTP_DOMAIN"],
    user_name:            ENV["EMAIL_FROM"],
    password:             ENV["SMTP_PASSWORD"],
    authentication:       'plain',
    enable_starttls_auto: true
  }
end
