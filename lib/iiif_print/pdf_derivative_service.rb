require 'open3'

module IiifPrint
  class PDFDerivativeService < BaseDerivativeService
    self.target_extension = 'pdf'.freeze

    # PDF (JPEG, 8 bit grayscale), 150ppi
    GRAY_PDF_CMD = 'convert %<source_file>s ' \
                   '-resize 1800 -density 150 ' \
                   '-depth 8 -colorspace Gray ' \
                   '-compress jpeg %<out_file>s'.freeze

    # sRBG color PDF (JPEG, 8 bits per channel), 150ppi
    COLOR_PDF_CMD = 'convert %<source_file>s ' \
                    '-resize 1800 -density 150 ' \
                    '-depth 8 ' \
                    '-compress jpeg %<out_file>s'.freeze

    def initialize(file_set)
      super(file_set)
    end

    # Get conversion command; command varies on whether or not we have
    #   JP2 source, and whether we have color or grayscale material.
    def convert_cmd
      template = use_color? ? COLOR_PDF_CMD : GRAY_PDF_CMD
      data = format(template, source_file: @source_path, out_file: @dest_path)
      IiifPrint.copy_derivatives_from_data_store(stream: data, directives: { url: file_set.id.to_s, container: 'service_file', mime_type: mime_type_for(target_extension) })
      data
    end

    def create_derivatives(filename)
      # Base class takes care of loading @source_path, @dest_path
      super(filename)

      # no creation if pdf master
      return if mime_type == 'application/pdf'

      # Get and run conversion command
      return jp2_convert if mime_type == 'image/jp2'
      im_convert
    end
  end
end
