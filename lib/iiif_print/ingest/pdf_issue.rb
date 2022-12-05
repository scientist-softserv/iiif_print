require 'date'

module IiifPrint
  module Ingest
    class PDFIssue
      attr_accessor :path, :publication

      # most acccessors for issue/edition metadata, publication metadata
      #   provided by including this mixin:
      include IiifPrint::Ingest::NamedIssueMetadata

      def initialize(path, publication)
        @path = path
        validate_path
        # as a IiifPrint::Ingest::PublicationInfo object:
        @publication = publication
      end
    end
  end
end
