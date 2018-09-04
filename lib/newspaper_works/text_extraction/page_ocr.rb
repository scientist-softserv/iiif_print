require 'json'
require 'open3'
require 'rtesseract'

# --
module NewspaperWorks
  # Module for text extraction (OCR or otherwise)
  module TextExtraction
    class PageOCR
      def self.alto_from(path)
        new(path).alto
      end

      def initialize(path)
        @path = path
        @words = nil
        @processor = "mini_magick"
        @source_meta = nil
        @use_gm = extension.start_with?('jp2')
        @box = nil
        @plain = nil
      end

      def extension
        @path.split('.')[-1].downcase
      end

      def load_box
        if @box.nil?
          if @use_gm
            MiniMagick.with_cli(:graphicsmagick) do
              @box = RTesseract::Box.new(@path, processor: @processor)
              @plain = @box.to_s
            end
          else
            @box = RTesseract::Box.new(@path, processor: @processor)
            @plain = @box.to_s
          end
        end
        @box
      end

      def words
        @words = load_box.words if @words.nil?
        @words
      end

      def normalized_coordinate(word)
        {
          word: word[:word],
          coordinates: [
            word[:x_start],
            word[:y_start],
            (word[:x_end] - word[:x_start]),
            (word[:y_end] - word[:y_start])
          ]
        }
      end

      def word_json
        save_words = words.map { |w| normalized_coordinate(w) }
        payload = { words: save_words }
        JSON.generate(payload)
      end

      def plain
        load_box
        @plain
      end

      def identify
        if @source_geometry.nil?
          path = @path
          cmd = "identify -verbose #{path}"
          cmd = 'gm ' + cmd if @use_gm
          lines = `#{cmd}`.lines
          geo = lines.select { |line| line.strip.start_with?('Geometry') }[0]
          img_geo = geo.strip.split(':')[-1].strip.split('+')[0]
          @source_geometry = img_geo.split('x').map(&:to_i)
        end
        @source_geometry
      end

      def width
        identify[0]
      end

      def height
        identify[1]
      end

      def alto
        writer = NewspaperWorks::TextExtraction::RenderAlto.new(width, height)
        writer.to_alto(words)
      end
    end
  end
end
