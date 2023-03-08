# frozen_string_literal: true

# override to add PDF splitting for file sets
module IiifPrint
  module Actors
    module FileSetActorDecorator
      def create_content(file, relation = :original_file, from_url: false)
        # Spawns asynchronous IngestJob unless ingesting from URL
        super

        if from_url
          # we have everything we need... queue the job
          parent = parent_for(file_set: @file_set)

          if service.iiif_print_split?(work: parent) && service.pdfs?(paths: [file_set.import_url])
            service.queue_job(
              work: parent,
              file_locations: [file.path],
              user: @user,
              admin_set_id: parent.admin_set_id
            )
          end
        else
          # we don't have the parent yet... save the paths for later use
          @pdf_paths = service.pdf_paths(files: [file.try(:id)&.to_s].compact)
        end
      end

      # Prior to Hyrax v3.1.0, this method did not exist
      # @param file_set [FileSet]
      # @return [ActiveFedora::Base]
      def parent_for(file_set:)
        file_set.parent
      end

      # Override to add PDF splitting
      def attach_to_work(work, file_set_params = {})
        # Locks to ensure that only one process is operating on the list at a time.
        super

        return if @pdf_paths.blank?
        return unless service.iiif_print_split?(work: work)
        service.queue_job(
          work: work,
          file_locations: @pdf_paths,
          user: @user,
          admin_set_id: work.admin_set_id
        )
      end

      def service
        IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService
      end
    end
  end
end
