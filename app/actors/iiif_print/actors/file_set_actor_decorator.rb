# frozen_string_literal: true

# override to add PDF splitting for file sets
module IiifPrint
  module Actors
    module FileSetActorDecorator
      def create_content(file, relation = :original_file, from_url: false)
        # Spawns asynchronous IngestJob unless ingesting from URL
        super

        if from_url
          service.conditionally_enqueue(file_set: file_set, file: file, import_url: file_set.import_url, user: @user)
        else
          # we don't have the parent yet... save the paths for later use
          @file = file
        end
      end

      # Override to add PDF splitting
      def attach_to_work(work, file_set_params = {})
        # Locks to ensure that only one process is operating on the list at a time.
        super

        service.conditionally_enqueue(file_set: file_set, work: work, file: @file, user: @user)
      end

      def service
        IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService
      end
    end
  end
end
