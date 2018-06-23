require 'dotenv'
Dotenv.load

require_relative "./dumb_holidays"

today = Time.now

#if !today.saturday? and !today.sunday?
  Slack.configure do |config|
    config.token = ENV['SLACK_BOT_TOKEN']
  end

  client = Slack::Web::Client.new

  DumbHolidays.new(client, ENV['CHANNEL']).run!
#end