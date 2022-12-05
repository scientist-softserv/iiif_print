module IiifPrint
  module Ingest
    # Represents TIFF/JP2 page, access to file, page-numbering metadata
    class PageImage
      attr_accessor :path, :issue, :sequence

      delegate :lccn, to: :issue

      def initialize(path, issue, sequence)
        # path to image:
        @path = path
        validate_path
        # Issue is IiifPrint::Ingest::IssueImages object
        @issue = issue
        # sequence is page sequence number (Integer)
        @sequence = sequence.to_i
      end

      # Page number inferred from image filename, or nil, presuming that:
      #   - The page number follows the actual word "page" (case-insenstive)
      #     in filename, possibly separated by a dash or underscore.
      #   - The page number is terminated by the period-plus-file-extension.
      #   - Both of the above can be determined by regular expression match.
      #   - Extraneous leading information in filename (e.g. datestamp) will
      #     be ignored.
      #   - Examples:
      #     - 'Page1.tiff'
      #     - '2019091801-page_1.jp2'
      #     - 'page_C2.tiff'
      # @return [String, NilClass] page number string, or nil if indecipherable
      def named_page_number
        pattern = /(page)([_-]?)([^.]+)([.])/i
        match = pattern.match(path)
        match.nil? ? nil : match[3]
      end

      def page_number
        named_page_number || @sequence.to_s
      end

      def title
        ["#{@issue.title.first}: Page #{page_number}"]
      end

      def validate_path
        # expect path to be regular file, that exists:
        raise ArgumentError unless File.exist?(path)
        raise ArgumentError unless File.ftype(path) == 'file'
      end
    end
  end
end
