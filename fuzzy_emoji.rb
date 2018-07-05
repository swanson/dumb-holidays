require "json"
require "fuzzy_match"

EMOJI_LIB = JSON.parse(File.open("./data/emojilib.json").read)

class FuzzyEmoji

  def initialize(available_emojis)
    @mapping = build_mapping(available_emojis)
    @fuzzy = FuzzyMatch.new(@mapping.keys)
  end

  def closest(target)
    return "no_mouth" if target == ""

    target_candidates = target.split.append(target)
    target_matches = target_candidates.map{|t| @fuzzy.find_with_score(t)}

    best_match = target_matches.max do |a,b|
      if a[1] == b[1]
        a[0].length <=> b[0].length
      else
        a[1] <=> b[1]
      end
    end
    @mapping[best_match[0]]
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