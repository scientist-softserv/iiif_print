# frozen_string_literal: true

# override to add PDF splitting for file sets and remove splitting upon fileset delete

# Depending on whether we have an uploaded file or a remote url, the sequence of calling
# attach_to_work and create_content will switch.
module IiifPrint
  module Actors
    module FileSetActorDecorator
      def create_content(file, relation = :original_file, from_url: false)
        # Spawns asynchronous IngestJob unless ingesting from URL
        super

        if from_url
          # in this case, the file that came in is a temp file, and we need to use the actual file.
          # the file was attached to the file_set in Hyrax::ImportUrlJob so we can just access it.
          args = { file_set: file_set, file: file_set.files.first, import_url: file_set.import_url, user: @user }
          returned_value = service.conditionally_enqueue(**args)
          Rails.logger.info("Result of #{returned_value} for conditional enqueueing of #{args.inspect}")
          true
        else
          # we don't have the parent yet... save the paths for later use
          @file = file
        end
      end

      # Override to add PDF splitting
      def attach_to_work(work, file_set_params = {})
        # Locks to ensure that only one process is operating on the list at a time.
        super

        # when we are importing a remote_url, this method is called before the file is attached.
        # We want to short-circuit the process and prevent unnecessarily confusing logging.
        return unless @file

        args = { file_set: file_set, work: work, file: @file, user: @user }
        returned_value = service.conditionally_enqueue(**args)
        Rails.logger.info("Result of #{returned_value} for conditional enqueueing of #{args.inspect}")
        true
      end

      def service
        IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService
      end

      # Clean up children when removing the fileset
      def destroy
        # we destroy the children before the file_set, because we need the parent relationship
        IiifPrint::SplitPdfs::DestroyPdfChildWorksService.conditionally_destroy_spawned_children_of(
          file_set: file_set,
          work: IiifPrint.parent_for(file_set)
        )
        # and now back to your regularly scheduled programming
        super
      end
    end
  end
end
Hyrax::Actors::FileSetActor.prepend(IiifPrint::Actors::FileSetActorDecorator)
