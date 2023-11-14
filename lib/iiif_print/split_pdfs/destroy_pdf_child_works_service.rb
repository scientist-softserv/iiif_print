# frozen_string_literal: true

module IiifPrint
  module SplitPdfs
    ## Encapsulates logic for cleanup when the PDF is destroyed after pdf splitting into child works
    class DestroyPdfChildWorksService
      ## @api public
      # @param file_set [FileSet] What is the containing file set for the provided file.
      # @param work [Hydra::PCDM::Work] Parent of the fileset being deleted
      def self.conditionally_destroy_spawned_children_of(file_set:, work:)
        child_model = work.try(:iiif_print_config)&.pdf_split_child_model
        return unless child_model
        return unless file_set.class.pdf_mime_types.include?(file_set.mime_type)

        IiifPrint::PendingRelationship.where(parent_id: work.id, file_id: file_set.id).each(&:destroy)
        destroy_spawned_children(model: child_model, file_set: file_set, work: work)
      end

      private_class_method def self.destroy_spawned_children(model:, file_set:, work:)
        # look first for children by the file set id they were split from
        children = model.where(split_from_pdf_id: file_set.id)
        if children.blank?
          # find works where file name and work `to_param` are both in the title
          children = model.where(title: file_set.label).where(title: work.to_param)
        end
        return if children.blank?
        children.each do |rcd|
          rcd.destroy(eradicate: true)
        end
      end
    end
  end
end
