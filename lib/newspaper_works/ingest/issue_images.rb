require 'date'
require 'find'

module NewspaperWorks
  module Ingest
    # Represents TIFF/JP2 issue, provides metadata, enumerates PageImage objects
    class IssueImages
      # most acccessors for issue/edition metadata, publication metadata
      #   provided by including this mixin:
      include NewspaperWorks::Ingest::NamedIssueMetadata

      # Path enumeration by mixing in Enumerable, PathEnumeration
      include Enumerable
      include NewspaperWorks::Ingest::PathEnumeration

      attr_accessor :path, :publication

      # things that look like images, by file extension:
      IMAGE_EXT = ['tiff', 'tif', 'jp2', 'jpg', 'png'].freeze

      def initialize(path, publication)
        @path = path
        raise ArgumentError, 'Path not directory' unless File.directory?(path)
        validate_path
        # as a NewspaperWorks::Ingest::PublicationInfo object:
        @publication = publication
        @pages = nil
      end

      def page_paths
        return @pages unless @pages.nil?
        @pages = []
        entries = Dir.entries(path).map { |n| File.join(path, n) }
        entries.sort.each do |p|
          next unless File.ftype(p) == 'file'
          ext = File.basename(p).downcase.split('.')[-1]
          next unless IMAGE_EXT.include?(ext)
          @pages.push(p)
        end
        @pages
      end

      def info(path)
        page_seq_num = page_paths.index(path) + 1
        NewspaperWorks::Ingest::PageImage.new(path, self, page_seq_num)
      end

      alias paths page_paths
    end
  end
end
