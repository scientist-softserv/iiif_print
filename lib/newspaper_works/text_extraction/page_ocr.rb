require 'json'
require 'open3'
require 'tmpdir'

# --
module NewspaperWorks
  # Module for text extraction (OCR or otherwise)
  module TextExtraction
    class PageOCR
      attr_accessor :html, :path

      def initialize(path)
        @path = path
        # hOCR html:
        @html = nil
        @words = nil
        @source_meta = nil
        @box = nil
        @plain = nil
      end

      def run_ocr
        outfile = File.join(Dir.mktmpdir, 'output_html')
        cmd = "tesseract #{path} #{outfile} hocr"
        `#{cmd}`
        outfile + '.hocr'
      end

      def load_words
        preprocess_image
        html_path = run_ocr
        reader = NewspaperWorks::TextExtraction::HOCRReader.new(html_path)
        @words = reader.words
        @plain = reader.text
      end

      def words
        load_words if @words.nil?
        @words
      end

      def word_json
        builder = NewspaperWorks::TextExtraction::WordCoordsBuilder.new(
          words,
          width,
          height
        )
        builder.to_json
      end

      def plain
        load_words if @plain.nil?
        @plain
      end

      def identify
        return @source_meta unless @source_meta.nil?
        @source_meta = NewspaperWorks::ImageTool.new(@path).metadata
      end

      def width
        identify[:width]
      end

      def height
        identify[:height]
      end

      def alto
        writer = NewspaperWorks::TextExtraction::RenderAlto.new(width, height)
        writer.to_alto(words)
      end

      private

        # transform the image into a one-bit TIFF for OCR
        def preprocess_image
          tool = NewspaperWorks::ImageTool.new(@path)
          return if tool.metadata[:color] == 'monochrome'
          intermediate_path = File.join(Dir.mktmpdir, 'monochrome-interim.tif')
          tool.convert(intermediate_path, true)
          @path = intermediate_path
        end
    end
  end
end
