# frozen_string_literal: true

module IiifPrint
  module Actors
    module FileSetActorDecorator
      def create_content(file, relation = :original_file, from_url: false)
        # If the file set doesn't have a title or label assigned, set a default.
        file_set.label ||= label_for(file)
        file_set.title = [file_set.label] if file_set.title.blank?
        @file_set = perform_save(file_set)
        return false unless file_set
        if from_url
          # If ingesting from URL, don't spawn an IngestJob; instead
          # reach into the FileActor and run the ingest with the file instance in
          # hand. Do this because we don't have the underlying UploadedFile instance
          file_actor = build_file_actor(relation)
          file_actor.ingest_file(wrapper!(file: file, relation: relation))
          parent = parent_for(file_set: file_set)
          VisibilityCopyJob.perform_later(parent)
          InheritPermissionsJob.perform_later(parent)

          return unless iiif_print?(parent)
          paths = [file_set.import_url]
          is_pdf = paths.select { |path| path.end_with?('.pdf', '.PDF') }
          return if is_pdf.blank?
          queue_job(parent, [file.path], @user, parent.admin_set_id, 0)

        else

          paths = [file.file.file.file]
          @pdf_paths = paths.select { |path| path.end_with?('.pdf', '.PDF') }

          IngestJob.perform_later(wrapper!(file: file, relation: relation))
        end
      end

      # Locks to ensure that only one process is operating on the list at a time.
      def attach_to_work(work, file_set_params = {})
        super
        return if @pdf_paths.blank?
        queue_job(work, @pdf_paths, @user, work.admin_set_id, 0) if iiif_print?(work)
      end

      private

      def iiif_print?(parent_work)
        @iiif_print_defined ||= parent_work.try(:iiif_print_config?)
      end

      # submit the job to create child works for PDF
      # @param [GenericWork, etc] A valid type of hyrax work
      # @param [Array<String>] paths to PDF attachments
      # @param [User] user
      # @param [String] admin set ID
      # @param [Integer] count of PDFs already existing on the parent work
      def queue_job(work, paths, user, admin_set_id, prior_pdfs)
        work.iiif_print_config.pdf_splitter_job.perform_later(
          work,
          paths,
          user,
          admin_set_id,
          prior_pdfs
        )
      end
    end
  end
end
