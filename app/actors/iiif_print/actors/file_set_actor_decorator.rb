# frozen_string_literal: true

# override to add PDF splitting for file sets and remove splitting upon fileset delete
module IiifPrint
  module Actors
    module FileSetActorDecorator
      def create_content(file, relation = :original_file, from_url: false)
        # Spawns asynchronous IngestJob unless ingesting from URL
        super

        if from_url
          args = { file_set: file_set, file: file, import_url: file_set.import_url, user: @user }
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
          work: file_set.parent
        )
        # and now back to your regularly scheduled programming
        super
      end
    end
  end
end
