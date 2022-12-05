require 'hyrax'

module IiifPrint
  module Data
    #   TODO: consider compositional refactoring (not mixins), but this
    #         may make readability/comprehendability higher, and yield
    #         higher applied/practical complexity.
    class WorkDerivatives
      include IiifPrint::Data::FilesetHelper
      include IiifPrint::Data::PathHelper

      # Work is primary adapted context
      # @return [ActiveFedora::Base] Hyrax work-type object
      attr_accessor :work

      # FileSet is secondary adapted context
      # @return [FileSet] fileset for work, with regard to these derivatives
      attr_accessor :fileset

      # Parent pointer to WorkFile object representing fileset
      # @return [IiifPrint::Data::WorkFile] WorkFile for fileset, work pair
      attr_accessor :parent

      # Assigned attachment queue (of paths)
      # @return [Array<String>] list of paths queued for attachment
      attr_accessor :assigned

      # Assigned deletion queue (of destination names)
      # @return [Array<String>] list of destination names queued for deletion
      attr_accessor :unassigned

      # mapping of special names Hyrax uses for derivatives, not extension:
      @remap_names = {
        'jpeg' => 'thumbnail'
      }
      class << self
        attr_accessor :remap_names
      end

      # @param from [Object] the work from which we'll extract the given type of data.
      # @param of_type [String] the type of data we want extracted from the work (e.g. "txt", "json")
      #
      # @return [String]
      def self.data(from:, of_type:)
        new(from).data(of_type)
      end

      # alternate constructor spelling:
      def self.of(work, fileset = nil, parent = nil)
        new(work, fileset, parent)
      end

      # Adapt work and either specific or first fileset
      def initialize(work, fileset = nil, parent = nil)
        # adapted context usually work, may be string id of FileSet
        @work = work
        @fileset = fileset.nil? ? first_fileset : fileset
        # computed name-to-path mapping, initially nil as sentinel for JIT load
        @paths = nil
        # assignments for attachment
        @assigned = []
        # un-assignments for deletion
        @unassigned = []
        # parent is IiifPrint::Data::WorkFile object for derivatives
        @parent = parent
      end

      # Assignment state
      # @return [String] A label describing the state of assignment queues
      def state
        load_paths
        return 'dirty' unless @unassigned.empty? && @assigned.empty?
        return 'empty' if @paths.keys.empty?
        'saved'
      end

      # Assign a path to assigned queue for attachment
      # @param path [String] Path to source file
      def assign(path)
        path = normalize_path(path)
        validate_path(path)
        @assigned.push(path)
        # We are keeping assignment both in ephemeral, transient @assigned
        #   and mirroring to db to share context with other components:
        log_assignment(path, path_destination_name(path))
      end

      # Assign a destination name to unassigned queue for deletion -- OR --
      #   remove a path from queue of assigned items
      # @param name [String] Destination name (file extension), or source path
      def unassign(name)
        # if name is queued path, remove from @assigned queue:
        if @assigned.include?(name)
          @assigned.delete(name)
          unlog_assignment(name, path_destination_name(name))
        end
        # if name is known destination name, remove
        @unassigned.push(name) if exist?(name)
      end

      # commit pending changes to work files
      #   beginning with removals, then with new assignments
      def commit!
        @unassigned.each { |name| delete(name) }
        @assigned.each do |path|
          attach(path, path_destination_name(path))
        end
        # reset queues after work is complete
        @assigned = []
        @unassigned = []
      end

      # Given a fileset meeting both of the following conditions:
      #   1. a non-nil import_url value;
      #   2. is attached to a work (persisted in Fedora, if not yet in Solr)...
      # ...this method gets associated derivative paths queued and attach all.
      # @param file_set [FileSet] saved file set, attached to work,
      #   with identifier, and a non-nil import_url
      def commit_queued!(file_set)
        raise ArgumentError, 'No FileSet import_url' if file_set.import_url.nil?
        import_path = file_url_to_path(file_set.import_url)
        work = file_set.member_of.select(&:work?)[0]
        raise ArgumentError, 'Work not found for fileset' if work.nil?
        derivatives = WorkDerivatives.of(work, file_set)
        IngestFileRelation.derivatives_for_file(import_path).each do |path|
          next unless File.exist?(path)
          attachment_record = DerivativeAttachment.where(path: path).first
          derivatives.attach(path, attachment_record.destination_name)
          # update previously nil fileset id
          attachment_record.fileset_id = file_set.id
          attachment_record.save!
        end
        @fileset ||= file_set
        load_paths
      end

      # attach a single derivative file to work
      # @param file [String, IO] path to file or IO object
      # @param name [String] destination name, usually file extension
      def attach(file, name)
        raise 'Cannot save for nil fileset' if fileset.nil?
        mkdir_pairtree
        path = path_factory.derivative_path_for_reference(fileset, name)
        # if file argument is path, copy file
        if file.class == String
          FileUtils.copy(file, path)
        else
          # otherwise, presume file is an IO, read, write it
          #   note: does not close input file/IO, presume that is caller's
          #   responsibility.
          orig_pos = file.tell
          file.seek(0)
          File.open(path, 'w') { |dstfile| dstfile.write(file.read) }
          file.seek(orig_pos)
        end
        # finally, reload @paths after mutation
        load_paths
      end

      # Delete a derivative file from work, by destination name
      # @param name [String] destination name, usually file extension
      def delete(name, force: nil)
        raise 'Cannot save for nil fileset' if fileset.nil?
        path = path_factory.derivative_path_for_reference(fileset, name)
        # will remove file, if it exists; won't remove pairtree, even
        #   if it becomes empty, as that is excess scope.
        FileUtils.rm(path, force: force) if File.exist?(path)
        # finally, reload @paths after mutation
        load_paths
      end

      # Load all paths/names to @paths once, upon first access
      def load_paths
        fsid = fileset_id
        if fsid.nil?
          @paths = {}
          return
        end
        # list of paths
        paths = path_factory.derivatives_for_reference(fsid)
        # names from paths
        @paths = paths.map { |e| [path_destination_name(e), e] }.to_h
      end

      # path to existing derivative file for destination name
      # @param name [String] destination name, usually file extension
      # @return [String, NilClass] path (or nil)
      def path(name)
        load_paths if @paths.nil?
        result = @paths[name]
        return if result.nil?
        File.exist?(result) ? result : nil
      end

      # Run a block in context of the opened derivative file for reading
      # @param name [String] destination name, usually file extension
      # @param block [Proc] block/proc to run in context of file IO
      def with_io(name, &block)
        mode = ['xml', 'txt', 'html'].include?(name) ? 'rb:UTF-8' : 'rb'
        filepath = path(name)
        return if filepath.nil?
        File.open(filepath, mode, &block)
      end

      # Get number of derivatives or, if a destination name argument
      #   is provided, the size of derivative file
      # @param name [String] optional destination name, usually file extension
      # @return [Integer] size in bytes
      def size(name = nil)
        load_paths if @paths.nil?
        return @paths.size if name.nil?
        File.size(@paths[name])
      end

      # Check if derivative file exists for destination name
      # @param name [String] optional destination name, usually file extension
      # @return [TrueClass, FalseClass] boolean
      def exist?(name)
        # TODO: It is unclear where the #keys and and #[] methods are coming from.  There's @paths.keys referenced in this code.
        keys.include?(name) && File.exist?(self[name])
      end

      # Get raw binary or encoded text data of file as a String
      # @param name [String] destination name, usually file extension
      # @return [String] Raw bytes, or if text file, a UTF-8 encoded String
      def data(name)
        result = ''
        with_io(name) do |io|
          result += io.read
        end
        result
      end

      private

      def primary_file_path
        if fileset.nil?
          # if there is a nil fileset, we look for *intent* in the form
          #   of the first assigned file path for single-file work.
          work_file = parent
          return if work_file.nil?
          work_files = work_file.parent
          return if work_files.nil?
          work_files.assigned[0]
        else
          file_url_to_path(fileset.import_url) unless fileset.import_url.nil?
        end
      end

      def file_url_to_path(url)
        url.gsub('file://', '')
      end

      def log_primary_file_relation(path)
        file_path = primary_file_path
        return if file_path.nil?
        IiifPrint::IngestFileRelation.create!(
          file_path: file_path,
          derivative_path: path
        )
      end

      def log_assignment(path, name)
        IiifPrint::DerivativeAttachment.create!(
          fileset_id: fileset_id,
          path: path,
          destination_name: name
        )
        log_primary_file_relation(path)
      end

      def unlog_assignment(path, name)
        if fileset_id.nil?
          IiifPrint::DerivativeAttachment.where(
            path: path,
            destination_name: name
          ).destroy_all
        else
          IiifPrint::DerivativeAttachment.where(
            fileset_id: fileset_id,
            path: path,
            destination_name: name
          ).destroy_all
        end
        # note: there is deliberately no attempt to "unlog" primary
        #   file relation, as leaving it should have no side-effect.
      end

      def path_destination_name(path)
        ext = path.split('.')[-1]
        self.class.remap_names[ext] || ext
      end

      def respond_to_missing?(symbol, include_priv = false)
        {}.respond_to?(symbol, include_priv)
      end

      def method_missing(method, *args, &block)
        # if we proxy mapping/hash enumertion methods,
        #   make sure @paths loaded, then proxy to it.
        if respond_to_missing?(method)
          load_paths if @paths.nil?
          return @paths.send(method, *args, &block)
        end
        super
      end

      def path_factory
        Hyrax::DerivativePath
      end

      # make shared path for derivatives to live, given
      def mkdir_pairtree
        # Hyrax::DerivativePath has no public method to directly get the
        #   bare pairtree path for derivatives for a fileset, but we
        #   can infer it...
        path = path_factory.derivative_path_for_reference(fileset, '')
        dir = File.join(path.split('/')[0..-2])
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      end
    end
  end
end
