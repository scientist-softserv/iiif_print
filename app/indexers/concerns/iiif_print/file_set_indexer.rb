# frozen_string_literal: true

module IiifPrint
  module FileSetIndexer
    extend ActiveSupport::Concern

    prepended do
      class_attribute :iiif_print_lineage_service, default: IiifPrint::LineageService
    end

    # for Valkyrie indexers
    def to_solr
      super.tap do |index_document|
        index_solr_doc(index_document)
      end
    end

    # for ActiveFedora indexers
    def generate_solr_document
      super.tap do |solr_doc|
        index_solr_doc(solr_doc)
      end
    end

    private

    def index_solr_doc(solr_doc)
      object ||= @object || resource

      # only UV viewable images should have is_page_of, it is only used for iiif search
      solr_doc['is_page_of_ssim'] = iiif_print_lineage_service.ancestor_ids_for(object) if image?(object)
      # index for full text search
      solr_doc['all_text_tsimv'] = solr_doc['all_text_timv'] = all_text(object)
      solr_doc['digest_ssim'] = digest_from_content(object)
    end

    def image?(object)
      mime_type = object.try(:mime_type) || object.original_file.mime_type
      mime_type&.match(/image/)
    end

    def digest_from_content(object)
      digest = object.original_file.try(:digest)&.first || object.original_file.try(:checksum)&.first
      return unless digest

      digest.to_s
    end

    def all_text(object)
      text = IiifPrint.config.all_text_generator_function.call(object: object) || ''
      return if text.empty?

      text.tr("\n", ' ').squeeze(' ')
    end
  end
end
