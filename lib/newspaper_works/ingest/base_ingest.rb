require 'newspaper_works/data'

module NewspaperWorks
  module Ingest
    # base class for ingesting works, implements, as-needed, temp files
    class BaseIngest
      include NewspaperWorks::Data::PathHelper

      attr_accessor :work, :io, :path, :filename

      def initialize(work)
        # adapted context:
        @work = work
      end

      def loadpath(source)
        # quick check the file exists and is readable on filesystem:
        raise ArgumentError, 'File not found or readable' unless
          File.readable?(source)
        # path may be relative to Dir.pwd, but no matter for our use
        @path = source.to_s
        @io = File.open(@path)
        @filename ||= File.split(@path)[-1]
      end

      def loadio(source)
        # either an IO with a path, or an IO with filename passed in
        #   args; presume we need a filename to describe/identify.
        raise ArgumentError, 'Explicit or inferred file name required' unless
          source.respond_to?('path') || @filename
        @io = source
        @path = source.respond_to?('path') ? source.path : nil
        @filename ||= File.split(@path)[-1]
      end

      def load(source, filename: nil)
        # source is a string path, Pathname object, or quacks like an IO
        unless source.class == String ||
               source.class == Pathname ||
               source.respond_to?('read')
          raise ArgumentError, 'Source is neither path nor IO object'
        end
        # permit the possibility of a filename identifier metadata distinct
        #   from the actual path on disk:
        @filename = filename
        ispath = source.class == String || source.class == Pathname
        loader = ispath ? method(:loadpath) : method(:loadio)
        loader.call(source)
      end

      # default handler attaches file to work's file set, subclasses
      #   may overwride or wrap this.
      def import
        files = NewspaperWorks::Data::WorkFiles.new(work)
        files.assign(path)
        files.commit!
      end

      def user
        defined?(current_user) ? current_user : User.batch_user
      end

      def ingest(source, filename: nil)
        load(source, filename: filename)
        import
      end
    end
  end
end
