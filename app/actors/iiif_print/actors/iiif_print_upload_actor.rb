module IiifPrint
  module Actors
    class IiifPrintUploadActor < Hyrax::Actors::AbstractActor
      # An actor which locates all uploaded PDF paths and
      # spins off IiifPrint::CreatePagesJob to split them.
      def create(env)
        # TODO: test what happens when ensure_title is removed.
        ensure_title(env)
        @pdf_paths = []
        hold_upload_paths(env) if responds_to_split?(env.curation_concern)
        next_actor.create(env) && after_other_actors(env)
      end

      def update(env)
        # TODO: test what happens when ensure_title is removed.
        ensure_title(env)
        @pdf_paths = []
        hold_upload_paths(env) if responds_to_split?(env.curation_concern)
        next_actor.update(env) && after_other_actors(env)
      end

      private

      # fill the array of pdf files' upload paths
      def hold_upload_paths(env)
        return unless env.attributes.keys.include? 'uploaded_files'
        upload_ids = filter_file_ids(env.attributes['uploaded_files'])
        return if upload_ids.empty?
        uploads = Hyrax::UploadedFile.find(upload_ids)
        paths = uploads.map(&method(:upload_path))
        @pdf_paths = paths.select { |path| path.end_with?('.pdf') }
      end

      def responds_to_split?(curation_concern)
        return true if curation_concern.respond_to?(:split_pdf)
        false
      end

      def after_other_actors(env)
        handle_issue_upload(env) if responds_to_split?(env.curation_concern)
        # needs to return true to not break actor stack traversal
        true
      end

      def handle_issue_upload(env)
        return if @pdf_paths.empty?
        work = env.curation_concern
        # must persist work to serialize job using it
        work.save!(validate: false)
        user = env.current_ability.current_user.user_key
        env.attributes[:admin_set_id] ||= default_admin_set
        queue_job(work, @pdf_paths, user, env.attributes[:admin_set_id])
      end

      def queue_job(work, paths, user, admin_set_id)
        IiifPrint::CreatePagesJob.perform_later(
          work,
          paths,
          user,
          admin_set_id
        )
      end

      # TODO: test what happens when ensure_title is removed... the
      # work is saved after all other actors, so this may be a non-issue?
      # Work must have a title to save, and this actor's .create/.update
      # methods run prior to the setting of form data.  This ensures
      # appropriate title is set on model.
      def ensure_title(env)
        form_title = env.attributes['title']
        return if form_title.nil?
        env.curation_concern.title = form_title
      end

      def default_admin_set
        AdminSet.find_or_create_default_admin_set_id
      end

      # Given Hyrax::Upload object, return path to file on local filesystem
      def upload_path(upload)
        # so many layers to this onion:
        upload.file.file.file
      end

      def filter_file_ids(input)
        Array.wrap(input).select(&:present?)
      end
    end
  end
end
