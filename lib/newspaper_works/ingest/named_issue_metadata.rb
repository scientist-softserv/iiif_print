require 'date'

module NewspaperWorks
  module Ingest
    # Mixin for deducing issue metadata from path, publication info.
    # precondition: consuming class has accessor for:
    #   - `path`: full path to issue
    #   - `publication`: a `NewspaperWorks::Ingest::PublicationInfo object.
    module NamedIssueMetadata
      # Memoized filename from path:
      # @return [String]
      def filename
        return @filename unless @filename.nil?
        @filename = File.basename(path)
      end

      def validate_path
        # expect path to exist:
        raise ArgumentError unless File.exist?(path)
        # `YYYYMMDDEE` with valid date digits, optional `EE` edition
        ptn = /^([0-9]{4})(1[012]|[0][1-9])(3[01]|[12][0-9]|0[1-9])([0-9]{2})?/
        raise ArgumentError unless ptn.match(filename)
      end

      # Publication date stamp
      # @return [String] ISO 8601 date stamp
      def publication_date
        year = filename.slice(0, 4).to_i
        month = filename.slice(4, 2).to_i
        day = filename.slice(6, 2).to_i
        DateTime.new(year, month, day).iso8601[0..9]
      end

      # Issue edition number
      # @return [Integer] number of issue edition
      def edition_number
        # use file name minus file extension (if applicable, e.g. PDF):
        base = filename.split('.')[0..-2].join('.')
        # default for PDF or issue dir not specifying edition value in
        #   name (before file extension, if applicable):
        return 1 if base.size < 10
        # ...otherwise use explicitly provided edition number in filename
        base.slice(8, 2).to_i
      end

      # rubocop:disable Rails/Delegate
      def lccn
        publication.lccn
      end
      # rubocop:enable Rails/Delegate

      def title
        title_date = DateTime.iso8601(publication_date).strftime('%B %-d, %Y')
        v = "#{publication.title}: #{title_date}"
        v = "#{v} (#{edition_number})" if edition_number.to_i > 1
        [v]
      end
    end
  end
end
