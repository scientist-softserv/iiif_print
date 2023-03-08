module IiifPrint
  module SplitPdfs
    # @abstract
    #
    # The purpose of this class is to split the PDF into constituent png files.
    #
    # @see #each
    class PagesToPngsSplitter < BaseSplitter
      self.image_extension = 'png'

      private

      def gsdevice
        color, _channels, bpc = pdfinfo.color
        device = nil
        # 1 Bit Grayscale, if applicable:
        device = 'pngmonod' if color == 'gray' && bpc == 1
        # 8 Bit Grayscale, if applicable:
        device = 'pnggray' if color == 'gray' && bpc > 1
        # otherwise 24 Bit RGB:
        device = 'png16m' if device.nil?
        device
      end
    end
  end
end
