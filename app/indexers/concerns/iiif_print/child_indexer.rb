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
        next unless work_type.respond_to?(:iiif_print_config?)
        next unless work_type.iiif_print_config?

        if IiifPrint.use_valkyrie?(work_type)
          indexer = decorate_valkyrie_resource(work_type)
        else
          indexer = decorate_af_object(work_type)
        end

        indexer.prepend(self).class_attribute(:iiif_print_lineage_service, default: IiifPrint::LineageService) unless indexer.respond_to?(:iiif_print_lineage_service)
        work_type::GeneratedResourceSchema.send(:include, IiifPrint::SetChildFlag) if work_type.const_defined?(:GeneratedResourceSchema)
      end
    end

    def self.decorate_valkyrie_resource(work_type)
      work_type.send(:include, Hyrax::Schema(:child_works_from_pdf_splitting)) unless work_type.included_modules.include?(Hyrax::Schema(:child_works_from_pdf_splitting))
      # TODO: Use `Hyrax::ValkyrieIndexer.indexer_class_for` once changes are merged.
      indexer = "#{work_type.to_s}Indexer".constantize
      indexer.send(:include, Hyrax::Indexer(:child_works_from_pdf_splitting)) unless indexer.included_modules.include?(Hyrax::Indexer(:child_works_from_pdf_splitting))
      indexer
    end

    def self.decorate_af_object(work_type)
      work_type.send(:include, IiifPrint::SetChildFlag) unless work_type.included_modules.include?(IiifPrint::SetChildFlag)
      work_type.indexer
    end

    def to_solr
      super.tap do |index_document|
        index_document['is_page_of_ssim'] = iiif_print_lineage_service.ancestor_ids_for(resource)

        # Due to a long-standing hack in Hyrax, the file_set_ids_ssim contains both file_set_ids and
        # child work ids.
        #
        # See https://github.com/samvera/hyrax/blob/2b807fe101176d594129ef8a8fe466d3d03a372b/app/indexers/hyrax/work_indexer.rb#L15-L18
        index_document['file_set_ids_ssim'] = iiif_print_lineage_service.descendent_member_ids_for(resource)
      end
    end

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['is_child_bsi'] ||= object.is_child
        solr_doc['split_from_pdf_id_ssi'] ||= object.split_from_pdf_id
        solr_doc['is_page_of_ssim'] = iiif_print_lineage_service.ancestor_ids_for(object)

        # Due to a long-standing hack in Hyrax, the file_set_ids_ssim contains both file_set_ids and
        # child work ids.
        #
        # See https://github.com/samvera/hyrax/blob/2b807fe101176d594129ef8a8fe466d3d03a372b/app/indexers/hyrax/work_indexer.rb#L15-L18
        solr_doc['file_set_ids_ssim'] = iiif_print_lineage_service.descendent_member_ids_for(object)
      end
    end
  end
end
