require_relative "./dumb_holidays"
require "pry"

input = ARGV.join(" ")

emojis = JSON.parse(File.open("./data/slack_emojis.json").read).map{|v| v["short_name"]}
@fuzzy_emoji = FuzzyEmoji.new(emojis)
@keyword_filter = KeywordFilter.new

def run(input = "")
  keyword = @keyword_filter.filter(input)
  match = @fuzzy_emoji.closest(keyword)

  puts ":#{match}: #{input}"
end

if input == "sample"
  File.open("./data/samples.txt").read.split("\n").each do |i|
    run i
  end
else
  run input
end