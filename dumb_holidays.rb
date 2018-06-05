require "excon"
require "slack-ruby-client"
require "json"
require "fuzzy_match"

class DumbHolidays

  HOLIDAY_FEED = "https://www.checkiday.com/rss.php?tz=America/Indianapolis"

  def initialize(slack_client, channel = "general")
    @slack = slack_client
    @channel = channel
    @emojis = @slack.emoji_list.emoji.keys
  end

  def run!(args = {})
    puts "Finding holidays for #{Time.now}"
    holidays = get_todays_holidays

    post_to_slack build_msg(holidays)
  end

  private
  def get_todays_holidays
    feed = Excon.get(HOLIDAY_FEED)
    xml = Hash.from_xml(feed.body)

    xml["rss"]["channel"]["item"].map{|i| i["title"]}
  end

  def post_to_slack(msg)
    puts "Sending to Slack:\n#{msg}"

    @slack.chat_postMessage(channel: @channel,
      text: msg,
      as_user: true
    )
  end

  def build_msg(holidays = [])
    msg = [":tada: *Today's Dumb Holidays* :tada:\n"]
    
    holidays.each do |h|
      keyword = find_keyword(h)
      closest_emoji = FuzzyMatch.new(slack_emojis).find(keyword)

      msg << ":#{closest_emoji}: #{h}"
    end

    msg << "\nFellow humans, please take a moment to celebrate these dumb holidays."

    msg.join("\n")
  end

  def find_keyword(title)
    title.downcase.gsub("day", "")
      .gsub("world", "")
      .gsub("earth", "")
      .gsub("national", "")
      .gsub("international", "")
      .gsub("festival", "")
      .gsub("the", "")
      .gsub("of", "")
      .gsub("your", "")
  end

  def slack_emojis
    standard = JSON.parse(File.open("./emojis.json").read).map{|v| v["short_name"]}
    custom = @slack.emoji_list.emoji.keys

    [standard, custom].flatten.sort
  end
end