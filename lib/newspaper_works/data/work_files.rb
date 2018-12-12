module NewspaperWorks
  module Data
    class WorkFiles
      include NewspaperWorks::Data::PathHelper

      attr_accessor :work, :assigned, :unassigned
      delegate :include?, to: :keys

      # alternate constructor spelling:
      def self.of(work)
        new(work)
      end

      def initialize(work)
        @work = work
        @assigned = []
        @unassigned = []
      end

      # Derivatives for specified fileset or first fileset found.
      #   The `WorkDerivatives` adapter as assign/commmit! semantics just
      #   like `WorkFiles`, and also acts like a hash/mapping of
      #   destination names (usually file extension) to path of saved
      #   derviative.
      # @return [NewspaperWorks::Data::WorkDerviatives] derivatives adapter
      def derivatives(fileset: nil)
        NewspaperWorks::Data::WorkDerivatives.of(work, fileset)
      end

      # Assignment state
      # @return [String] A label describing the state of assignment queues
      def state
        return 'dirty' unless @assigned.empty? && @unassigned.empty?
        return 'empty' if keys.empty?
        # TODO: implement 'pending' as intermediate state between 'dirty'
        #   and saved, where we look for saved state that matches what was
        #   previously assigned in THIS instance.  We can only know that
        #   changes initiated by this instance in this thread are pending
        #   because there's no global storage for the assignment queue.
        'saved'
      end

      # List of fileset (not file) id keys, presumes system like Hyrax
      #   is only keeping a 1:1 between fileset and contained PCDM file,
      #   because derivatives are not stored in the FileSet.
      # @return [String] fileset ids
      def keys
        filesets.map(&:id)
      end

      # List of WorkFile for each primary file
      # @return [Array<NewspaperWorks::Data::WorkFile>] adapter for persisted
      #   primary file
      def values
        keys.map(&method(:get))
      end

      # Array of [id, WorkFile] for each primary file
      # @return [Array<Array>] key/value pairs for primary files of work
      def entries
        filesets.map { |fs| [fs.id, self[fs.id]] }
      end

      # List of local file names for attachments, based on original ingested
      #   or uploaded file name.
      # @return [Array<String>]
      def names
        filesets.map(&method(:original_name))
      end

      # Get a WorkFile adapter representing primary file, either by name or id
      # @param name_or_id [String] Fileset id or work-local file name
      # @return [NewspaperWorks::Data::WorkFile] adapter for persisted
      #   primary file
      def get(name_or_id)
        return get_by_fileset_id(name_or_id) if keys.include?(name_or_id)
        get_by_filename(name_or_id)
      end

      # Assign a path to assigned queue for attachment
      # @param path [String] Path to source file
      def assign(path)
        path = normalize_path(path)
        validate_path(path)
        @assigned.push(path)
      end

      # Assign a name or id to unassigned queue for deletion -- OR -- remove a
      #   path from queue of assigned items
      # @param name_or_id [String] Fileset id, local file name, or source path
      def unassign(name_or_id)
        # if name_or_id is queued path, remove from @assigned queue:
        @assigned.delete(name_or_id) if @assigned.include?(name_or_id)
        # if name_or_id is known id or name, remove
        @unassigned.push(name_or_id) if include?(name_or_id)
      end

      # commit pending changes to work files
      #   beginning with removals, then with new assignments
      def commit!
        commit_unassigned
        commit_assigned
      end

      alias [] :get

      private

        def get_by_fileset_id(id)
          nil unless keys.include?(id)
          fileset = FileSet.find(id)
          NewspaperWorks::Data::WorkFile.of(work, fileset, self)
        end

        # Get one WorkFile object based on filename in metadata
        def get_by_filename(name)
          r = filesets.select { |fs| original_name(fs) == name }
          # checkout first match
          r.empty? ? nil : NewspaperWorks::Data::WorkFile.of(work, r[0], self)
        end

        def original_name(fileset)
          fileset.original_file.original_name
        end

        def filesets
          # file sets with non-nil original file contained:
          work.members.select { |m| m.class == FileSet && m.original_file }
        end

        def user
          defined?(current_user) ? current_user : User.batch_user
        end

        def ensure_depositor
          return unless @work.depositor.nil?
          @work.depositor = user.user_key
        end

        def commit_unassigned
          # for each (name or) id to be removed from work, use actor to destroy
          @unassigned.each do |id|
            # "actor" here is simply a multi-adapter of Fileset, User
            # Calling destroy will:
            #   1. unlink fileset from work, and save work
            #   2. Destroy fileset:
            #     - :before_destroy callback will delegate derivative cleanup
            #       to derivatives service component(s).
            #     - Remove fileset from storage/persistence layers
            #     - Invoke (logging or other) :after_destroy callback
            Hyrax::Actors::FileSetActor.new(get(id).fileset, user).destroy
            work.reload
          end
        end

        def commit_assigned
          return if @assigned.nil? || @assigned.empty?
          ensure_depositor
          remote_files = @assigned.map do |path|
            { url: path_to_uri(path), file_name: File.basename(path) }
          end
          attrs = { remote_files: remote_files }
          # Create an environment for actor stack:
          env = Hyrax::Actors::Environment.new(@work, Ability.new(user), attrs)
          # Invoke default Hyrax actor stack middleware:
          Hyrax::CurationConcern.actor.create(env)
        end
    end
  end
end
