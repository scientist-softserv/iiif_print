require 'open3'

module NewspaperWorks
  class TIFFDerivativeService < NewspaperPageDerivativeService
    TARGET_EXT = 'tiff'.freeze

    # For imagemagick commands, the output type is determined by the
    #   output file's extension.
    # TIFF (LZW, 8 bit grayscale)
    GRAY_CMD = 'convert %<source_file>s ' \
               '-depth 8 -colorspace Gray ' \
               '-compress lzw %<out_file>s'.freeze

    # Monochrome one-bit black/white TIFF, Group 4 compressed:
    MONO_CMD = 'convert %<source_file>s ' \
               '-depth 1 -monochrome -compress Group4 -type bilevel ' \
               '%<out_file>s'.freeze

    # sRBG color TIFF (8 bits per channel, lzw)
    COLOR_CMD = 'convert %<source_file>s ' \
                '-depth 24 ' \
                '-compress lzw %<out_file>s'.freeze

    # graphicsmagick prefix, may be needed for jp2 source on Ubuntu
    GM_PREFX = 'gm '.freeze

    def initialize(file_set)
      super(file_set)
    end

    # Get conversion command; command varies on whether or not we have
    #   JP2 source, and whether we have color or grayscale material.
    def convert_cmd
      source_path = @source_path
      source_path += '[0]' if @source_path.ends_with?('pdf')
      template = use_color? ? COLOR_CMD : GRAY_CMD
      template = MONO_CMD if one_bit?
      cmd = format(template, source_file: source_path, out_file: @dest_path)
      # normalization of command based on source
      @source_path.ends_with?('jp2') ? GM_PREFIX + cmd : cmd
    end

    def create_derivatives(filename)
      # Base class takes care of loading @source_path, @dest_path
      super(filename)

      # no creation if pdf master
      return if mime_type == 'image/tiff'

      # Get and run imagemagick or graphicsmagick command
      `#{convert_cmd}`
    end
  end
end
