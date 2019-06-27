module NewspaperWorks
  # Module for text extraction (OCR or otherwise)
  module TextExtraction
    class WordCoordsBuilder
      def initialize(words, width = nil, height = nil)
        @words = words
        @width = width
        @height = height
      end

      # Output JSON flattened word coordinates
      #
      # @return [String] JSON serialization of flattened word coordinates
      def to_json
        coordinates = {}
        @words.each do |w|
          word_chars = w[:word]
          word_coords = w[:coordinates]
          if coordinates[word_chars]
            coordinates[word_chars] << word_coords
          else
            coordinates[word_chars] = [word_coords]
          end
        end
        payload = { width: @width, height: @height, coords: coordinates }
        JSON.generate(payload)
      end
    end
  end
end
