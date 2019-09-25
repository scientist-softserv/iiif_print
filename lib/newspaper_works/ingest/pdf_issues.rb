require 'find'

module NewspaperWorks
  module Ingest
    class PDFIssues
      include Enumerable
      include NewspaperWorks::Ingest::PathEnumeration

      attr_accessor :path, :publication, :pdf_paths

      alias paths pdf_paths

      def initialize(path, publication)
        @path = path
        # as a NewspaperWorks::Ingest::PublicationInfo object:
        @publication = publication
        @pdf_paths = valid_pdfs(path)
      end

      def valid_pdfs(path)
        target = []
        Find.find(path) do |p|
          next if File.directory?(p)
          next unless p.end_with?('.pdf')
          target.push(p)
        end
        target
      end

      def lccn
        @publication.lccn
      end

      def info(path)
        NewspaperWorks::Ingest::PDFIssue.new(path, @publication)
      end
    end
  end
end
