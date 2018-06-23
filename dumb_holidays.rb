require "excon"
require "slack-ruby-client"
require "json"
require "fuzzy_match"
require "stopwords"

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

    keyword_filter = KeywordFilter.new
    fuzzy_matcher = FuzzyMatch.new(slack_emojis)

    holidays.each do |holiday|
      keyword = keyword_filter.filter(holiday)
      closest_emoji = fuzzy_matcher.find(keyword)

      msg << ":#{closest_emoji}: #{holiday}"
    end

    msg << "\nFellow humans, please take a moment to celebrate these dumb holidays."

    msg.join("\n")
  end

  def slack_emojis
    standard = JSON.parse(File.open("./emojis.json").read).map{|v| v["short_name"]}
    custom = @slack.emoji_list.emoji.keys

    [standard, custom].flatten.sort
  end
end

class KeywordFilter

  SPACE = " "

  def filter(source = "")
    source
      .downcase
      .strip
      .split(SPACE)
      .reject{|w| Stopwords.is? w }
      .reject{|w| HolidayStopwords.is? w }
      .join(SPACE)
  end
end

class HolidayStopwords

  STOP_WORDS = %{
    american
    appreciation
    awareness
    day
    earth
    festival
    global
    go
    international
    language
    national
    pride
    solidarity
    take
    tech
    thing
    work
    worker
    world
    worldwide
  }

  def self.is?(word)
    STOP_WORDS.include? word
  end
end
