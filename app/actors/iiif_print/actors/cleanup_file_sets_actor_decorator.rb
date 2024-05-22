# frozen_string_literal: true

# override Hyrax to remove splitting upon work delete
module IiifPrint
  module Actors
    # Responsible for removing FileSets related to the given curation concern.
    module CleanupFileSetsActorDecorator
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if destroy was successful
      def destroy(env)
        file_sets = env.curation_concern.file_sets
        file_sets.each do |file_set|
          # we destroy the children before the file_set, because we need the parent relationship
          IiifPrint::SplitPdfs::DestroyPdfChildWorksService.conditionally_destroy_spawned_children_of(
            file_set: file_set,
            work: env.curation_concern
          )
        end
        # and now back to your regularly scheduled programming
        super
      end
    end
  end
end
Hyrax::Actors::CleanupFileSetsActor.prepend(IiifPrint::Actors::CleanupFileSetsActorDecorator)
