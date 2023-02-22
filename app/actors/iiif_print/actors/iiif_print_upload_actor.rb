# frozen_string_literal: true

module IiifPrint
  module Actors
    class IiifPrintUploadActor < Hyrax::Actors::AbstractActor
      # An actor which locates all uploaded PDF paths and
      # spins off IiifPrint::ChildWorksFromPdfJob to split them.
      def create(env)
    #    ensure_title(env)
       # @pdf_paths = hold_upload_paths(env)
        next_actor.create(env) # && after_other_actors(env)
      end

      def update(env)
    #    ensure_title(env)
    #    @pdf_paths = hold_upload_paths(env)
        next_actor.update(env) # && after_other_actors(env)
      end

      private

      def service
        IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService
      end

      # fill & save an array of pdf files' upload paths
      def hold_upload_paths(env)
        return [] unless env.attributes.keys.include? 'uploaded_files'
        service.pdf_paths(files: env.attributes['uploaded_files'])
      end

      def after_other_actors(env)
        handle_issue_upload(env)
        # needs to return true to not break actor stack traversal
        true
      end

      def handle_issue_upload(env)
        return if @pdf_paths.empty?
        work = env.curation_concern
        return unless service.iiif_print_split?(work: work)
        # must persist work to serialize job using it
        work.save!(validate: false)
        admin_set_id = env.attributes[:admin_set_id] ||= default_admin_set
        service.queue_job(
          work: work,
          file_locations: @pdf_paths,
          user: env.current_ability.current_user,
          admin_set_id: admin_set_id
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
        return AdminSet.find_or_create_default_admin_set_id unless defined?(Hyrax::AdminSetCreateService)

        Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s
      end
    end
  end
end
