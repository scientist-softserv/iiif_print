# frozen_string_literal: true

module IiifPrint
  module FileSetIndexer
    include IiifPrint::IiifPrintBehavior
    include IiifPrint::IndexesFullText
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def generate_solr_document
      super.tap do |solr_doc|
        # only UV viewable images should have is_page_of, it is only used for iiif search
        solr_doc['is_page_of_ssim']         = [ancestor_ids(object)] if object.mime_type&.match(/image/)
        index_full_text(object, solr_doc)
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
    private 

    ##
    # relationship indexing for fileset and works
    #
    # @param o [Object] a work object
    # @return [Array] array of child work ids
    # rubocop:disable Rails/OutputSafety
    def ancestor_ids(o)
      a_ids = []
      o.in_works.each do |work|
        a_ids << work.id
        a_ids += ancestor_ids(work) if work.is_child
      end
      a_ids
    end 
  end
end
