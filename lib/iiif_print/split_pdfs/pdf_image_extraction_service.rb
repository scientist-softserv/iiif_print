require 'open3'
require 'mini_magick'

module IiifPrint
  module SplitPdfs
    # Uses poppler 0.19+ pdfimages command to extract image
    #   listing metadata from PDF files.
    # For dpi extraction, falls back to calculating using MiniMagick,
    #   if neccessary.
    class PdfImageExtractionService
      # class constant column numbers
      COL_WIDTH = 3
      COL_HEIGHT = 4
      COL_COLOR = 5
      COL_CHANNELS = 6
      COL_BITS = 7
      # only poppler 0.25+ has this column in output:
      COL_XPPI = 12

      def initialize(path)
        @path = path
        @cmd = format('pdfimages -list %<path>s', path: path)
        @output = nil
        @entries = nil
      end

      def entries
        if @entries.nil?
          @entries = []
          output = process
          (0..output.size - 1).each do |i|
            @entries.push(output[i].gsub(/\s+/m, ' ').strip.split(" "))
          end
        end
        @entries
      end

      def page_count
        @entries.length
      end

      def selectcolumn(i, &block)
        result = entries.map { |e| e[i] }
        return result.map!(&block) if block_given?
        result
      end

      def width
        selectcolumn(COL_WIDTH, &:to_i).max
      end

      def height
        selectcolumn(COL_HEIGHT, &:to_i).max
      end

      def color
        # desc is either 'gray', 'cmyk', 'rgb', but 1-bit gray is black/white
        #   so caller may want all of this information, and in case of
        #   mixed color spaces across images, this returns maximum
        desc = entries.any? { |e| e[COL_COLOR] != 'gray' } ? 'rgb' : 'gray'
        channels = entries.map { |e| e[COL_CHANNELS].to_i }.max
        bits = entries.map { |e| e[COL_BITS].to_i }.max
        [desc, channels, bits]
      end

      def ppi
        if entries[0].size <= 12
          # poppler < 0.25
          pdf = MiniMagick::Image.open(@path)
          width_points = pdf.width
          width_px = width
          return (72 * width_px / width_points).to_i
        end
        # with poppler 0.25+, pdfimages just gives us this:
        selectcolumn(COL_XPPI, &:to_i).max
      end

      private

      def process
        # call just once
        if @output.nil?
          Open3.popen3(@cmd) do |_stdin, stdout, _stderr, _wait_thr|
            @output = stdout.read.split("\n")
          end
        end
        # The first two lines are tabular header information:
        #
        # Example:
        #
        #   bash-5.1$ pdfimages -list fmc_color.pdf  | head -5
        #   page   num  type   width height color comp bpc  enc interp  object ID x-ppi y-ppi size ratio
        #   --------------------------------------------------------------------------------------------
        #   1     0 image    2475   413  rgb     3   8  jpeg   no        10  0   300   300 21.8K 0.7%
        @output[2..-1]
      end
    end
  end
end
