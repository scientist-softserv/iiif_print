# frozen_string_literal: true

module IiifPrint
  module FileSetIndexer
    # Why `.decorate`?  In my tests for Rails 5.2, I'm not able to use the prepended nor included
    # blocks to assign a class_attribute when I "prepend" a module to the base class.  This method
    # allows me to handle that behavior.
    #
    # @param base [Class]
    # @return [Class] the given base, now decorated in all of it's glory
    def self.decorate(base)
      base.prepend(self)
      base.class_attribute :iiif_print_lineage_service, default: IiifPrint::LineageService
      base
    end
    include IndexesFullText
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def generate_solr_document
      super.tap do |solr_doc|
        # only UV viewable images should have is_page_of, it is only used for iiif search
        solr_doc['is_page_of_ssim'] = iiif_print_lineage_service.ancestor_ids_for(object) if object.mime_type&.match(/image/)
        solr_doc['all_text_tsimv'] = object.extracted_text.content if object.try(:extracted_text).try(:content)&.present?
        index_full_text(object, solr_doc)
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
