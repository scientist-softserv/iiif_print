# frozen_string_literal: true

module IiifPrint
  module ChildIndexer
    ##
    # @api private
    #
    # The goal of this method is to encapsulate the logic for what all we need for child
    # relationships.
    def self.decorate_work_types!
      # TODO: This method is in the wrong location; says indexing but there's also the SetChildFlag
      # consideration.  Consider refactoring this stuff into a single nested module.
      #

      Hyrax.config.curation_concerns.each do |work_type|
        work_type.send(:include, IiifPrint::SetChildFlag) unless work_type.included_modules.include?(IiifPrint::SetChildFlag)
        indexer = work_type.indexer
        unless indexer.respond_to?(:iiif_print_lineage_service)
          indexer.prepend(self)
          indexer.class_attribute(:iiif_print_lineage_service, default: IiifPrint::LineageService)
        end
        work_type::GeneratedResourceSchema.send(:include, IiifPrint::SetChildFlag)
      end
    end

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['is_child_bsi'] = object.is_child
        solr_doc['is_page_of_ssim'] = iiif_print_lineage_service.ancestor_ids_for(object)
        solr_doc['file_set_ids_ssim'] = iiif_print_lineage_service.descendent_file_set_ids_for(object)
      end
    end
  end
end
