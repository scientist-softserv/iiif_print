require 'date'

module NewspaperWorks
  module Ingest
    class PDFIssue
      attr_accessor :path, :publication

      def initialize(path, publication)
        @path = path
        # as a NewspaperWorks::Ingest::PublicationInfo object:
        @publication = publication
      end

      def filename
        File.basename(@path)
      end

      # @return [String] ISO 8601 date stamp
      def publication_date
        year = filename.slice(0, 4).to_i
        month = filename.slice(4, 2).to_i
        day = filename.slice(6, 2).to_i
        DateTime.new(year, month, day).iso8601[0..9]
      end

      def edition_number
        # use file name minus file extension:
        base = filename.split('.')[0..-2].join('.')
        # default for PDF files not specifying edition value before ext...
        return 1 if base.size < 10
        # ...otherwise use explicitly provided edition number in filename
        base.slice(8, 2).to_i
      end

      def lccn
        @publication.lccn
      end

      def title
        title_date = DateTime.iso8601(publication_date).strftime('%B %-d, %Y')
        v = "#{@publication.title}: #{title_date}"
        v = "#{v} (#{edition_number})" if edition_number.to_i > 1
        [v]
      end
    end
  end
end
