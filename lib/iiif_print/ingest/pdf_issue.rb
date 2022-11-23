require 'date'

module NewspaperWorks
  module Ingest
    class PDFIssue
      attr_accessor :path, :publication

      # most acccessors for issue/edition metadata, publication metadata
      #   provided by including this mixin:
      include NewspaperWorks::Ingest::NamedIssueMetadata

      def initialize(path, publication)
        @path = path
        validate_path
        # as a NewspaperWorks::Ingest::PublicationInfo object:
        @publication = publication
      end
    end
  end
end
