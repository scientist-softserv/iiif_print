# frozen_string_literal: true

# OVERRIDE: Bulkrax v.3.5

module Bulkrax
  module CreateRelationshipsJobDecorator
    attr_accessor :child_records, :parent_record, :parent_entry, :importer_run_id

    def create_relationships
      if parent_record.is_a?(::Collection)
        collection_parent_work_child unless child_records[:works].empty?
        collection_parent_collection_child unless child_records[:collections].empty?
      else
        work_parent_work_child unless child_records[:works].empty?
        child_records[:works].each do |work|
          # reindex filesets to update solr's is_page_of_ssim
          work.file_sets.each(&:update_index)
        end
        # OVERRIDE: Bulkrax v.3.5
        # set the first child's thumbnail as the thumbnail for the parent
        IiifPrint::SetDefaultParentThumbnailJob.set(wait: 10.minutes)
                                      .perform_later(parent_work: parent_record, importer_run_id: importer_run_id)

        if child_records[:collections].present?
          raise ::StandardError, 'a Collection may not be assigned as a child of a Work'
        end
      end
    end
  end
end

Bulkrax::CreateRelationshipsJob.prepend(Bulkrax::CreateRelationshipsJobDecorator)
