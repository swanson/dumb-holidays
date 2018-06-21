require "excon"
require "slack-ruby-client"
require "json"
require "fuzzy_match"

class DumbHolidays

  HOLIDAY_FEED = "https://www.checkiday.com/rss.php?tz=America/Indianapolis"

  def initialize(slack_client, channel = "general")
    @slack = slack_client
    @channel = channel
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

    fuzzy_matcher = FuzzyMatch.new(slack_emojis)

    holidays.each do |holiday|
      cleaned = clean(holiday)
      closest_emoji = fuzzy_matcher.find(cleaned)

      msg << ":#{closest_emoji}: #{holiday}"
    end

    msg << "\nFellow humans, please take a moment to celebrate these dumb holidays."

    msg.join("\n")
  end

  def strip_words(string, words)
    words.each_with_object(string) do |word, accum|
      accum.gsub!(/\b#{word}\b/i, "")
    end
  end

  def clean(holiday)
    strip_words(holiday, [
      "day",
      "world",
      "earth",
      "international",
      "national",
      "festival",
      "the",
      "of",
      "your",
    ])
  end

  def slack_emojis
    standard = JSON.parse(File.open("./emojis.json").read).map{|v| v["short_name"]}
    custom = @slack.emoji_list.emoji.keys

    [standard, custom].flatten.sort
  end
end
