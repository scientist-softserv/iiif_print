require 'open3'

module IiifPrint
  class TIFFDerivativeService < PageDerivativeService
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
      format(template, source_file: source_path, out_file: @dest_path)
    end

    def create_derivatives(filename)
      # Base class takes care of loading @source_path, @dest_path
      super(filename)

      # no creation of TIFF deriviative if primary is TIFF
      return if mime_type == 'image/tiff'

      return jp2_convert if mime_type == 'image/jp2'
      # Otherwise, get, run imagemagick command to convert
      im_convert
    end
  end
end
