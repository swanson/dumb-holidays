require "json"
require "fuzzy_match"

EMOJI_LIB = JSON.parse(File.open("./data/emojilib.json").read)

class FuzzyEmoji

  def initialize(available_emojis)
    @mapping = build_mapping(available_emojis)
    @fuzzy = FuzzyMatch.new(@mapping.keys)
  end

  def closest(target)
    @mapping[@fuzzy.find(target)]
  end

  private
  
  def build_mapping(emojis)
    mapping = Hash.new

    emojis.each do |emoji|
      keywords = []

      if EMOJI_LIB[emoji]
        keywords = EMOJI_LIB[emoji]["keywords"]
      end

      keywords.each do |k|
        unless mapping[k]
          mapping[k] = emoji
        end
      end

      mapping[emoji] = emoji
    end

    mapping
  end
end