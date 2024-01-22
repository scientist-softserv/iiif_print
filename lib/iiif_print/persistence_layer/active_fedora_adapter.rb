module IiifPrint
  module PersistenceLayer
    class ActiveFedoraAdapter < AbstractAdapter

      ##
      # @param object [ActiveFedora::Base]
      # @return [Array<SolrDocument>]
      def self.object_in_works(object)
        object.in_works
      end

      ##
      # @param object [ActiveFedora::Base]
      # @return [Array<SolrDocument>]
      def self.object_ordered_works(object)
        object.ordered_works
      end

      def self.decorate_with_adapter_logic(work_type:)
        work_type.send(:include, IiifPrint::SetChildFlag) unless work_type.included_modules.include?(IiifPrint::SetChildFlag)
        work_type.indexer
      end

      ##
      # Return the immediate parent of the given :file_set.
      #
      # @param file_set [FileSet]
      # @return [#work?, Hydra::PCDM::Work]
      # @return [NilClass] when no parent is found.
      def self.parent_for(file_set)
        # fallback to Fedora-stored relationships if work's aggregation of
        #   file set is not indexed in Solr
        file_set.parent || file_set.member_of.find(&:work?)
      end

      ##
      # Return the parent's parent of the given :file_set.
      #
      # @param file_set [FileSet]
      # @return [#work?, Hydra::PCDM::Work]
      # @return [NilClass] when no grand parent is found.
      def self.grandparent_for(file_set)
        parent_of_file_set = parent_for(file_set)
        # HACK: This is an assumption about the file_set structure, namely that an image page split from
        # a PDF is part of a file set that is a child of a work that is a child of a single work.  That
        # is, it only has one grand parent.  Which is a reasonable assumption for IIIF Print but is not
        # valid when extended beyond IIIF Print.  That is GenericWork does not have a parent method but
        # does have a parents method.
        parent_of_file_set.try(:parent_works).try(:first) ||
          parent_of_file_set.try(:parents).try(:first) ||
          parent_of_file_set&.member_of&.find(&:work?)
      end

      def self.solr_construct_query(*args)
        if defined?(Hyrax::SolrQueryBuilderService)
          Hyrax::SolrQueryBuilderService.construct_query(*args)
        else
          ActiveFedora::SolrQueryBuilderService.construct_query(*args)
        end
      end

      def self.clean_for_tests!
        super do
          ActiveFedora::Cleaner.clean!
        end
      end

      def self.solr_query(*args)
        if defined?(Hyrax::SolrService)
          Hyrax::SolrService.query(*args)
        else
          ActiveFedora::SolrService.query(*args)
        end
      end

      def self.solr_name(field_name)
        if defined?(Hyrax) && Hyrax.config.respond_to?(:index_field_mapper)
          Hyrax.config.index_field_mapper.solr_name(field_name.to_s)
        else
          ::ActiveFedora.index_field_mapper.solr_name(field_name.to_s)
        end
      end

      ##
      # @param file_set [Object]
      # @param work [Object]
      # @param model [Class] The class name for which we'll split children.
      def self.destroy_children_split_from(file_set:, work:, model:)
        # look first for children by the file set id they were split from
        children = model.where(split_from_pdf_id: file_set.id)
        if children.blank?
          # find works where file name and work `to_param` are both in the title
          children = model.where(title: file_set.label).where(title: work.to_param)
        end
        return if children.blank?
        children.each do |rcd|
          rcd.destroy(eradicate: true)
        end
        true
      end
    end
  end
end
