require 'date'
require 'find'
require 'optparse'

module NewspaperWorks
  module Ingest
    module NDNP
      class BatchIngester
        include NewspaperWorks::Logging

        attr_accessor :path, :batch

        # alternate constructor from ARGV
        # @param options [Array<String>]
        def self.from_command(options, cmd_name)
          path = batch_path(options, cmd_name)
          missing_path(cmd_name) if path.nil?
          path = xml_path(path)
          missing_path(cmd_name, "Not found: #{path}") unless File.exist?(path)
          Hyrax.config.whitelisted_ingest_dirs.push(File.dirname(path))
          new(path)
        end

        def self.missing_path(cmd_name, msg = "Missing path argument")
          STDERR.puts "Usage: #{cmd_name} -- --path=PATH"
          STDERR.puts "#{msg}. Exiting."
          # rubocop:disable Rails/Exit
          exit(1) if cmd_name.start_with?('rake')
          # rubocop:enable Rails/Exit
        end

        def self.batch_path(options, cmd_name)
          path = nil
          parser = OptionParser.new
          args = parser.order!(options) {}
          parser.banner = "Usage: #{cmd_name} -- --path=PATH"
          parser.on('-i PATH', '--path PATH') do |p|
            path = p
          end
          parser.parse!(args)
          path
        end

        def self.xml_path(path)
          return path unless File.directory?(path)
          batch_xml_path = Find.find(path).select do |f|
            f.downcase.end_with?('batch_1.xml', 'batch.xml')
          end
          batch_xml_path.find { |f| f.end_with?('_1.xml') } || batch_xml_path[0]
        end

        def initialize(path)
          @path = self.class.xml_path(path)
          raise IOError, "No batch file found: #{path}" if @path.empty?
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
            NewspaperWorks::Ingest::NDNP::IssueIngester.new(issue, batch)
          end

          def normalize_date(v)
            (v.is_a?(String) ? Date.parse(v) : v).to_s
          end
      end
    end
  end
end
