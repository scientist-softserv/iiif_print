# encoding=utf-8

require 'hyrax'

module NewspaperWorks
  module Data
    # WorkFile is a read-only convenience wrapper for just-in-time
    #   file operations, and is the type of values returned by
    #   NewspaperWorks::Data::WorkFiles (container) adapter.
    class WorkFile
      # accessors for adaptation relationships:
      attr_accessor :work, :parent, :fileset
      # delegate these metadata properties to @fileset.original_file:
      delegate :size, :date_created, :date_modified, :mime_type, to: :unwrapped

      # alternate constructor spelling:
      def self.of(work, fileset = nil, parent = nil)
        new(work, fileset, parent)
      end

      def initialize(work, fileset = nil, parent = nil)
        @work = work
        # If fileset is nil, presume *first* fileset of work, as in
        #   the single-file-per-work use-case:
        @fileset = fileset
        # Parent is WorkFiles (container) object, if applciable:
        @parent = parent
      end

      # Get original repository object representing file (not fileset).
      # @return [ActiveFedora::File] repository file persistence object
      def unwrapped
        return nil if @fileset.nil?
        @fileset.original_file
      end

      def ==(other)
        return false if @fileset.nil?
        unwrapped.id == other.unwrapped.id
      end

      # Get path to working copy of file on local filesystem;
      #   checkout file from repository/source as needed.
      # @return [String] path to working copy of binary
      def path
        return nil if @fileset.nil?
        checkout
      end

      # Read data from working copy of file on local filesystem;
      #   checkout file from repository/source as needed.
      # @return [String] byte data of binary/file payload
      def data
        return '' if @fileset.nil?
        File.read(path, mode: 'rb')
      end

      # Run block/proc upon data of file;
      #   checkout file from repository/source as needed.
      # @yield [io] read-only IO or File object to block/proc.
      def with_io(&block)
        filepath = path
        return if filepath.nil?
        File.open(filepath, 'rb', &block)
      end

      # Get filename from stored metadata
      # @return [String] file name stored in repository metadata for file
      def name
        return nil if @fileset.nil?
        unwrapped.original_name
      end

      # Derivatives for fileset associated with this primary file object
      # @return [NewspaperWorks::Data::WorkDerviatives] derivatives adapter
      def derivatives
        NewspaperWorks::Data::WorkDerivatives.of(work, fileset, self)
      end

      private

        def checkout
          file = @fileset.original_file
          # find_or_retrieve returns path to working copy, but only
          #   fetches from Fedora if no working copy exists on filesystem.
          # NOTE: there may be some benefit to memoizing to avoid
          #   call and File.exist? IO operation, but YAGNI for now.
          Hyrax::WorkingDirectory.find_or_retrieve(file.id, @fileset.id)
        end
    end
  end
end
