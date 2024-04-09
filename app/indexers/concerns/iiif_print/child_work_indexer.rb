# frozen_string_literal: true

module IiifPrint
  module ChildWorkIndexer
    def to_solr
      super.tap do |index_document|
        index_solr_doc(index_document)
      end
    end

    def generate_solr_document
      super.tap do |solr_doc|
        index_solr_doc(solr_doc)
      end
    end

    private

    def index_solr_doc(solr_doc)
      object ||= @object || resource

      solr_doc['is_child_bsi'] ||= object.is_child
      solr_doc['split_from_pdf_id_ssi'] ||= object.split_from_pdf_id
      solr_doc['is_page_of_ssim'] = iiif_print_lineage_service.ancestor_ids_for(object)
      solr_doc['member_ids_ssim'] = iiif_print_lineage_service.descendent_member_ids_for(object)
    end
  end
end
