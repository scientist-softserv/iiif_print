# frozen_string_literal: true

module IiifPrint
  module FileSetIndexer
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
      # only UV viewable images should have is_page_of, it is only used for iiif search
      solr_doc['is_page_of_ssim'] = IiifPrint::LineageService.ancestor_ids_for(object) if image?(object)
      # index for full text search
      solr_doc['all_text_tsimv'] = solr_doc['all_text_timv'] = all_text(object)
      solr_doc['digest_ssim'] = find_checksum(object)
    end

    def image?(object)
      mime_type = object.try(:mime_type) || object.original_file.try(:mime_type)
      mime_type&.match(/image/)
    end

    def find_checksum(object)
      file = object.original_file
      return unless file

      digest ||= if file.is_a?(Hyrax::FileMetadata)
                   Array.wrap(file.checksum).first
                 else # file is a Hydra::PCDM::File (ActiveFedora)
                   file.digest.first
                 end
      return unless digest

      digest.to_s
    end

    def all_text(object)
      file = object.original_file
      return unless file

      text = IiifPrint.extract_text_for(file_set: object)
      return text if text.blank?

      text.tr("\n", ' ').squeeze(' ')
    end
  end
end
