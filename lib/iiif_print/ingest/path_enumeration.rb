module NewspaperWorks
  module Ingest
    # Provides enumeration of path keys to object values, where:
    #   - Consuming class:
    #     - Defines a `paths` method returning array of paths.
    #     - Defines an `info` method that returns an object for a path.
    #     - Also mixes in Enumerable
    module PathEnumeration
      delegate :size, :include?, to: :_paths

      def _paths
        paths
      end

      def _info(path)
        info(path)
      end

      def each
        return enum_for(:each) unless block_given?
        paths.each do |path|
          yield [path, info(path)]
        end
      end

      def each_key
        enum_for(:each_key) unless block_given?
        paths.each { |path| yield path }
      end

      def each_value
        return enum_for(:each_value) unless block_given?
        paths.each do |path|
          yield info(path)
        end
      end

      def values
        each_value.to_a
      end

      def entries
        each.to_a
      end

      alias each_pair each
      alias keys _paths
      alias has_key? include?
      alias [] _info
    end
  end
end
