require 'dotenv/load'
require_relative "./dumb_holidays"

Slack.configure do |config|
  config.token = ENV['SLACK_BOT_TOKEN']
end

client = Slack::Web::Client.new

DumbHolidays.new(client, ENV['CHANNEL']).run!