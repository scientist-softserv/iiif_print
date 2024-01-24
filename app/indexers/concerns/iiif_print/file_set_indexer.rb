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
      decorate_index_document_method(base)
      base
    end

    ##
    # Decorate the appropriate indexing document based on the type of indexer; namely whether it
    # responds to `#to_solr` or `#generate_solr_document`.
    #
    # @param base [Class]
    # @return [Class]
    def self.decorate_index_document_method(base)
      ##
      # We want to first favor extending :to_solr, then favor :generate_solr_document
      #
      # What if the underlying class doesn't have :generate_solr_document?  There are other
      # problems.
      #
      # https://github.com/samvera/hyrax/blob/3a82b3d513047e270848cd394c97fa4ac60e5b14/app/indexers/hyrax/indexers/resource_indexer.rb#L66-L85
      method_name = if base.instance_methods.include?(:to_solr)
                      :to_solr
                    else
                      :generate_solr_document
                    end

      # Providing these as wayfinding for searching projects:
      #
      # def to_solr
      # def generate_solr_document
      base.define_method(method_name) do |*args|
        super(*args).tap do |solr_doc|
          # only UV viewable images should have is_page_of, it is only used for iiif search
          solr_doc['is_page_of_ssim'] = iiif_print_lineage_service.ancestor_ids_for(object) if object.mime_type&.match(/image/)
          # index for full text search
          solr_doc['all_text_timv'] = all_text
          solr_doc['all_text_tsimv'] = all_text
          solr_doc['digest_ssim'] = digest_from_content
        end
      end

      base
    end
    private_class_method :decorate_index_document_method

    private

    def digest_from_content
      return unless object.original_file
      object.original_file.digest.first.to_s
    end

    def all_text
      text = IiifPrint.config.all_text_generator_function.call(object: object) || ''
      return text if text.empty?

      text.tr("\n", ' ').squeeze(' ')
    end
  end
end
