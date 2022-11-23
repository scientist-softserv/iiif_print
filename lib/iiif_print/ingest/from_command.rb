module IiifPrint
  module Ingest
    # class-method mixin module for ingest command-line invocation
    #   usage in classes: `extend IiifPrint::Ingest::FromCommand`
    #   These are all expected to be class methods in various CLI ingests.
    module FromCommand
      # alternate constructor from ARGV
      # @param options [Array<String>]
      def from_command(options, cmd_name)
        path, opts = batch_path(options, cmd_name)
        missing_path(cmd_name) if path.nil?
        path = normalize_path(path)
        missing_path(cmd_name, "Not found: #{path}") unless File.exist?(path)
        Hyrax.config.whitelisted_ingest_dirs.push(File.dirname(path))
        new(path, opts)
      end

      def missing_path(cmd_name, msg = "Missing path argument")
        STDERR.puts "Usage: #{cmd_name} -- --path=PATH"
        STDERR.puts "#{msg}. Exiting."
        # rubocop:disable Rails/Exit
        exit(1) if cmd_name.start_with?('rake')
        # rubocop:enable Rails/Exit
      end

      def batch_path(options, cmd_name)
        path = nil
        params = {}
        parser = OptionParser.new
        args = parser.order!(options) {}
        parser.banner = "Usage: #{cmd_name} -- --path=PATH"
        parser.on('-i PATH', '--path PATH') do |p|
          path = p
        end
        parser.on('--admin_set=ADMIN_SET')
        parser.on('--depositor=DEPOSITOR')
        parser.on('--visibility=VISIBILITY')
        # lccn used by PDF issue ingest, but not NDNP ingest:
        parser.on('--lccn=LCCN')
        parser.parse!(args, into: params)
        [path, params]
      end

      # default normalization is no normalization of path
      # @param path [String]
      # @return [String]
      def normalize_path(path)
        path
      end
    end
  end
end
