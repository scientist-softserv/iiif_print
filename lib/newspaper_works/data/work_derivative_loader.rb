require 'hyrax'

module NewspaperWorks
  module Data
    class WorkDerivativeLoader
      def initialize(work)
        @context = work
        # storage for computed paths are memoized as used, here:
        @paths = {}
      end

      def path_factory
        Hyrax::DerivativePath
      end

      def derivative_path(fsid, name)
        if @paths[name].nil?
          result = path_factory.derivative_path_for_reference(fsid, name)
          @paths[name] = result
        end
        @paths[name]
      end

      def fileset_id
        filesets = @context.members.select { |m| m.class == FileSet }
        filesets.empty? ? nil : filesets[0].id
      end

      def path(name)
        fsid = fileset_id
        return nil if fsid.nil?
        result = derivative_path(fsid, name)
        File.exist?(result) ? result : nil
      end

      def with_io(name, &block)
        filepath = path(name)
        return if filepath.nil?
        File.open(filepath, 'r', &block)
      end

      def data(name)
        result = ''
        with_io(name) do |io|
          result += io.read
        end
        result
      end
    end
  end
end
