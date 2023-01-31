# frozen_string_literal: true

module IiifPrint
  module FileSetIndexer
    include IiifPrintBehavior
    include IndexesFullText
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def generate_solr_document
      super.tap do |solr_doc|
        # only UV viewable images should have is_page_of, it is only used for iiif search
        solr_doc['is_page_of_ssim'] = [ancestor_ids(object)] if object.mime_type&.match(/image/)
        solr_doc['all_text_tsimv'] = object.extracted_text.content if object.try(:extracted_text).try(:content)&.present?
        index_full_text(object, solr_doc)
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
  end
end
