require 'hyrax'

module NewspaperWorks
  module Data
    class WorkDerivativeLoader
      include Enumerable

      def initialize(work)
        # context usually work, may be FileSet, may be string id of FileSet
        @context = work
        # storage for computed paths are memoized as used, here:
        @paths = {}
      end

      # all paths for work derivatives
      def paths
        path_factory.derivatives_for_reference(fileset_id)
      end

      # enumerates available file extensions
      def each
        paths.each do |e|
          yield(e.split('.')[-1])
        end
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
        # if context is itself a string, presume it is a file set id
        return @context if @context.class == String
        # context might be a FileSet...
        return @context if @context.class == FileSet
        # ...or a work:
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
