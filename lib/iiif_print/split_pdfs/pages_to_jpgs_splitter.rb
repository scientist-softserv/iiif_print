module IiifPrint
  module SplitPdfs
    # @abstract
    #
    # The purpose of this class is to split the PDF into constituent jpg files.
    #
    # @see #each
    class PagesToJpgsSplitter < BaseSplitter
      self.image_extension = 'jpg'
      DEFAULT_QUALITY = '50'.freeze
      self.quality = DEFAULT_QUALITY

      private

      def gsdevice
        'jpeg'
      end
    end
  end
end
