module IiifPrint
  module SplitPdfs
    # The purpose of this class is to split the PDF into constituent TIFF files.
    #
    # @see #each
    class PagesToTiffsSplitter < BaseSplitter
      self.image_extension = 'tiff'

      private

      def gsdevice
        color, channels, bpc = pdfinfo.color
        device = nil
        if color == 'gray'
          # CCITT Group 4 Black and White, if applicable:
          if bpc == 1
            device = 'tiffg4'
            @compression = 'g4'
          elsif bpc > 1
            # 8 Bit Grayscale, if applicable:
            device = 'tiffgray'
          end
        end

        # otherwise color:
        device = colordevice(channels, bpc) if device.nil?
        device
      end

      def colordevice(channels, bpc)
        bits = bpc * channels
        # will be either 8bpc/16bpd color TIFF,
        #   with any CMYK source transformed to 8bpc RBG
        bits = 24 unless [24, 48].include? bits
        "tiff#{bits}nc"
      end
    end
  end
end
