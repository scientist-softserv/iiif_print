require 'date'
require 'find'
require 'optparse'

module NewspaperWorks
  module Ingest
    module NDNP
      class BatchIngester
        extend NewspaperWorks::Ingest::FromCommand
        include NewspaperWorks::Logging

        attr_accessor :path, :batch, :opts

        # normalize path, possibly from directory, to contained batch
        #   manifest XML path:
        # @param path [String]
        def self.normalize_path(path)
          return path unless File.directory?(path)
          batch_xml_path = Find.find(path).select do |f|
            f.downcase.end_with?('batch_1.xml', 'batch.xml')
          end
          batch_xml_path.find { |f| f.end_with?('_1.xml') } || batch_xml_path[0]
        end

        # @param path [String] path to batch xml or directory
        # @param opts [Hash]
        #   global ingest options, to be passed to ingester components,
        #   may include administrative metadata.
        def initialize(path, opts = {})
          @path = self.class.normalize_path(path)
          raise IOError, "No batch file found: #{path}" if @path.empty?
          @opts = opts
          @batch = batch_enumerator
          configure_logger('ingest')
        end

        def ingest
          write_log("Beginning NDNP batch ingest for #{@path}")
          batch.each do |issue|
            issue_ingester(issue).ingest
          end
          write_log(
            "NDNP batch ingest complete!"
          )
        end

        private

          # Return BatchIngest object as enumerable of issues:
        def batch_enumerator
          NewspaperWorks::Ingest::NDNP::BatchXMLIngest.new(path)
        end

        def issue_ingester(issue)
          NewspaperWorks::Ingest::NDNP::IssueIngester.new(issue, @opts)
        end

        def normalize_date(v)
          (v.is_a?(String) ? Date.parse(v) : v).to_s
        end
      end
    end
  end
end
