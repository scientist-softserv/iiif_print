module IiifPrint
  module Jobs
    ##
    # Encapsulates logic for cleanup when the PDF is destroyed after pdf splitting into child works
    class RequestSplitPdfJob < IiifPrint::Jobs::ApplicationJob
      ##
      # @param file_set [FileSet]
      # @param user [User]
      # rubocop:disable Metrics/MethodLength
      def perform(file_set:, user:)
        return true unless file_set.pdf?

        work = IiifPrint.parent_for(file_set)

        # Woe is ye who changes the configuration of the model, thus removing the splitting.
        raise WorkNotConfiguredToSplitFileSetError.new(work: work, file_set: file_set) unless work&.iiif_print_config&.pdf_splitter_job&.presence

        # clean up any existing spawned child works of this file_set
        IiifPrint::SplitPdfs::DestroyPdfChildWorksService.conditionally_destroy_spawned_children_of(
          file_set: file_set,
          work: work
        )

        location = Hyrax::WorkingDirectory.find_or_retrieve(file_set.files.first.id, file_set.id)

        # submit a job to split pdf into child works
        work.iiif_print_config.pdf_splitter_job.perform_later(
          file_set,
          [location],
          user,
          work.admin_set_id,
          0 # A no longer used parameter; but we need to preserve the method signature (for now)
        )
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
