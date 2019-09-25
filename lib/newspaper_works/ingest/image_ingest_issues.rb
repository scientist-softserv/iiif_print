module NewspaperWorks
  module Ingest
    class ImageIngestIssues
      include Enumerable
      include NewspaperWorks::Ingest::PathEnumeration

      attr_accessor :path, :publication

      delegate :lccn, to: :publication

      def initialize(path, publication)
        # path is path to publication directory containing issues:
        @path = path
        # Publication info
        @publication = publication
        @issue_paths = nil
      end

      def paths
        return @issue_paths unless @issue_paths.nil?
        result = []
        entries = Dir.entries(path).map { |n| File.join(path, n) }
        entries.select { |p| !File.basename(p).start_with?('.') }.each do |p|
          next unless File.directory?(p)
          next unless path_validates?(p)
          result.push(p)
        end
        @issue_paths = result
      end

      def info(path)
        NewspaperWorks::Ingest::IssueImages.new(path, @publication)
      end

      private

        def path_validates?(p)
          ptn = /^([0-9]{4})(1[012]|[0][1-9])(3[01]|[12][0-9]|0[1-9])([0-9]{2})?/
          ptn.match(File.basename(p)) ? true : false
        end
    end
  end
end
