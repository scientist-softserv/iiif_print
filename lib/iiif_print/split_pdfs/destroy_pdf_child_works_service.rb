# frozen_string_literal: true

module IiifPrint
  module SplitPdfs
    ## Encapsulates logic for cleanup when the PDF is destroyed after pdf splitting into child works
    class DestroyPdfChildWorksService
      ## @api public
      # @param file_set [FileSet] What is the containing file set for the provided file.
      # @param work [Hydra::PCDM::Work] Parent of the fileset being deleted
      def self.conditionally_destroy_spawned_children_of(file_set:, work:, user: nil)
        child_model = work.try(:iiif_print_config)&.pdf_split_child_model
        return unless child_model
        return unless IiifPrint.pdf?(file_set)

        # NOTE: The IiifPrint::PendingRelationship is an ActiveRecord object; hence we don't need to
        # leverage an adapter.
        IiifPrint::PendingRelationship.where(parent_id: work.id, file_id: file_set.id).find_each(&:destroy)
        IiifPrint.destroy_children_split_from(file_set: file_set, work: work, model: child_model, user: user)
      end
    end
  end
end
