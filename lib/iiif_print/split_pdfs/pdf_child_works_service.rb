# frozen_string_literal: true

module IiifPrint
  module SplitPdfs
    ## Encapsulates logic for cleanup when the PDF is destroyed after pdf splitting into child works
    class PdfChildWorksService
      def self.create_pdf_child_works_for(file_set:, user:)
        locations = pdfs_only_for([Hyrax::WorkingDirectory.find_or_retrieve(file.id, file_set.id)])
        return if locations.empty?
        work = IiifPrint.parent_for(file_set)

        # clean up any existing spawned child works of this file_set
        IiifPrint::SplitPdfs::DestroyPdfChildWorksService.conditionally_destroy_spawned_children_of(
          file_set: file_set,
          work: work
        )

        # submit a job to split pdf into child works
        work.iiif_print_config.pdf_splitter_job.perform_later(
          file_set,
          locations,
          user,
          work.admin_set_id,
          0 # A no longer used parameter; but we need to preserve the method signature (for now)
        )
      end

      # @todo: can we use mimetype instead?
      def self.pdfs_only_for(paths)
        paths.select { |path| path.end_with?('.pdf', '.PDF') }
      end
    end
  end
end