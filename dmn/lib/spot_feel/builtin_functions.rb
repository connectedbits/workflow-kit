# frozen_string_literal: true

module SpotFeel
  def self.builtin_functions
    {
      # String functions
      "substring": ->(string, start, length) { string[start - 1, length] },
      "substring before": ->(string, match) { string.split(match).first },
      "substring after": ->(string, match) { string.split(match).last },
      "string length": ->(string) { string.length },
      "upper case": ->(string) { string.upcase },
      "lower case": -> (string) { string.downcase },
      "contains": ->(string, match) { string.include?(match) },
      "starts with": ->(string, match) { string.start_with?(match) },
      "ends with": ->(string, match) { string.end_with?(match) },
      "matches": ->(string, match) { string.match?(match) },
      "replace": ->(string, match, replacement) { string.gsub(match, replacement) },
      "split": ->(string, match) { string.split(match) },
    }
  end
end
