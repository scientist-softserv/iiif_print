require 'find'
require 'date'

module NewspaperWorks
  module Ingest
    module NDNP
      class BatchIngester
        attr_accessor :path, :batch

        def initialize(path)
          @path = xml_path(path)
          @batch = batch_enumerator
        end

        def ingest
          batch.each do |issue|
            issue_ingester(issue).ingest
          end
        end

        private

          # Return BatchIngest object as enumerable of issues:
          def batch_enumerator
            NewspaperWorks::Ingest::NDNP::BatchXMLIngest.new(path)
          end

          def issue_ingester(issue)
            NewspaperWorks::Ingest::NDNP::IssueIngester.new(issue, batch)
          end

          def normalize_date(v)
            (v.is_a?(String) ? Date.parse(v) : v).to_s
          end

          def xml_path(path)
            return path unless File.directory?(path)
            batch_path = Find.find(path).select do |f|
              f.downcase.end_with?('batch_1.xml')
            end
            raise IOError, 'Batch file not found: #{path}' if batch_path.empty?
            batch_path[0]
          end
      end
    end
  end
end
