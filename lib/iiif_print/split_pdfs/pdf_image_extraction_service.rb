require 'open3'
require 'mini_magick'

module IiifPrint
  module SplitPdfs
    # Uses poppler 0.19+ pdfimages command to extract image
    #   listing metadata from PDF files.
    # For dpi extraction, falls back to calculating using MiniMagick,
    #   if neccessary.
    class PdfImageExtractionService
      def initialize(path)
        @path = path
        process(command: format('pdfimages -list %<path>s', path: path))
      end

      attr_reader :path, :page_count, :width, :height, :pixels_per_inch
      alias ppi pixels_per_inch

      # @return [Array<String, Integer, Integer>]
      def color
        [@color_description, @channels, @bits]
      end

      private

      # class constant column numbers
      COL_WIDTH = 3
      COL_HEIGHT = 4
      COL_COLOR_DESC = 5
      COL_CHANNELS = 6
      COL_BITS = 7
      # only poppler 0.25+ has this column in output:
      COL_XPPI = 12

      # rubocop:disable Metrics/AbcSize - Because this helps us process the results in one loop.
      # rubocop:disable Metrics/MethodLength - Again, to help speed up the processing loop.
      #
      # The first two lines are tabular header information:
      #
      # Example:
      #
      #   bash-5.1$ pdfimages -list fmc_color.pdf  | head -5
      #   page   num  type   width height color comp bpc  enc interp  object ID x-ppi y-ppi size ratio
      #   --------------------------------------------------------------------------------------------
      #   1     0 image    2475   413  rgb     3   8  jpeg   no        10  0   300   300 21.8K 0.7%
      def process(command:)
        @page_count = 0
        @color_description = 'gray'
        @width = 0
        @height = 0
        @channels = 0
        @bits = 0
        @pixels_per_inch = 0
        Open3.popen3(command) do |_stdin, stdout, _stderr, _wait_thr|
          stdout.read.split("\n").each_with_index do |line, index|
            # Skip the two header lines
            next if index <= 1
            @page_count += 1
            cells = line.gsub(/\s+/m, ' ').strip.split(" ")

            @color_description = 'rgb' if cells[COL_COLOR_DESC] != 'gray'
            @width = cells[COL_WIDTH].to_i if cells[COL_WIDTH].to_i > @width
            @height = cells[COL_HEIGHT].to_i if cells[COL_HEIGHT].to_i > @height
            @channels = cells[COL_CHANNELS].to_i if cells[COL_CHANNELS].to_i > @channels
            @bits = cells[COL_BITS].to_i if cells[COL_BITS].to_i > @bits

            # In the case of poppler version < 0.25, we will have no more than 12 columns.  As such,
            # we need to do some alternative magic to calculate this.
            if @page_count == 1 && cells.size <= 12
              pdf = MiniMagick::Image.open(@path)
              width_points = pdf.width
              width_px = width
              @pixels_per_inch = (72 * width_px / width_points).to_i
            else
              # By the magic of nil#to_i if we don't have more than 12 columns, we've already set
              # the @pixels_per_inch and this line won't due much of anything.
              @pixels_per_inch = cells[COL_XPPI].to_i if cells[COL_XPPI].to_i > @pixels_per_inch
            end
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
