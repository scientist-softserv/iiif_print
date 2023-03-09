require 'json'
require 'open3'
require 'tmpdir'

# --
module IiifPrint
  # Module for text extraction (OCR or otherwise)
  module TextExtraction
    class PageOCR
      attr_accessor :html, :path

      def initialize(path, additional_tessearct_options: IiifPrint.config.additional_tessearct_options)
        @path = path
        # hOCR html:
        @html = nil
        @words = nil
        @source_meta = nil
        @box = nil
        @plain = nil
        @additional_tessearct_options = additional_tessearct_options
      end

      def run_ocr
        outfile = File.join(Dir.mktmpdir, 'output_html')
        cmd = "tesseract #{path} #{outfile}"
        cmd += " #{@additional_tessearct_options}" if @additional_tessearct_options.present?
        cmd += " hocr"
        `#{cmd}`
        outfile + '.hocr'
      end

      def load_words
        preprocess_image
        html_path = run_ocr
        reader = IiifPrint::TextExtraction::HOCRReader.new(html_path)
        @words = reader.words
        @plain = reader.text
      end

      def words
        load_words if @words.nil?
        @words
      end

      def word_json
        IiifPrint::TextExtraction::WordCoordsBuilder.json_coordinates_for(
          words: words,
          width: width,
          height: height
        )
      end

      def plain
        load_words if @plain.nil?
        @plain
      end

      def identify
        return @source_meta unless @source_meta.nil?
        @source_meta = IiifPrint::ImageTool.new(@path).metadata
      end

      def width
        identify[:width]
      end

      def height
        identify[:height]
      end

      def alto
        writer = IiifPrint::TextExtraction::RenderAlto.new(width, height)
        writer.to_alto(words)
      end

      private

      # transform the image into a one-bit TIFF for OCR
      def preprocess_image
        tool = IiifPrint::ImageTool.new(@path)
        return if tool.metadata[:color] == 'monochrome'
        intermediate_path = File.join(Dir.mktmpdir, 'monochrome-interim.tif')
        tool.convert(intermediate_path, true)
        @path = intermediate_path
      end
    end
  end
end
