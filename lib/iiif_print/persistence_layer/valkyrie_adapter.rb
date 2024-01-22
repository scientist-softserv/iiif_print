module IiifPrint
  module PersistenceLayer
    class ValkyrieAdapter < AbstractAdapter
      def self.decorate_with_adapter_logic(work_type:)
        work_type.send(:include, Hyrax::Schema(:child_works_from_pdf_splitting)) unless work_type.included_modules.include?(Hyrax::Schema(:child_works_from_pdf_splitting))
        # TODO: Use `Hyrax::ValkyrieIndexer.indexer_class_for` once changes are merged.
        indexer = "#{work_type.to_s}Indexer".constantize
        indexer.send(:include, Hyrax::Indexer(:child_works_from_pdf_splitting)) unless indexer.included_modules.include?(Hyrax::Indexer(:child_works_from_pdf_splitting))
      end

      ##
      # Return the immediate parent of the given :file_set.
      #
      # @param file_set [FileSet]
      # @return [#work?, Hydra::PCDM::Work]
      # @return [NilClass] when no parent is found.
      def self.parent_for(file_set)
        Hyrax.index_adapter.find_parents(resource: file_set).first
      end

      ##
      # Return the parent's parent of the given :file_set.
      #
      # @param file_set [FileSet]
      # @return [#work?, Hydra::PCDM::Work]
      # @return [NilClass] when no grand parent is found.
      def self.grandparent_for(file_set)
        parent = Hyrax.index_adapter.find_parents(resource: file_set).first
        return nil unless parent
        Hyrax.index_adapter.find_parents(resource: parent).first
      end

      def self.solr_construct_query(*args)
        Hyrax::SolrQueryBuilderService.construct_query(*args)
      end

      def self.clean_for_tests!
        # For Fedora backed repositories, we'll want to consider some cleaning mechanism.  For
        # database backed repositories, we can rely on the database_cleaner gem.
        raise NotImplementedError
      end

      def self.solr_query(*args)
        Hyrax::SolrService.query(*args)
      end

      def self.solr_name(field_name)
        Hyrax.config.index_field_mapper.solr_name(field_name.to_s)
      end

      ##
      # @todo implement this logic
      def self.destroy_children_split_from(file_set:, work:, model:)
        super
      end
    end
  end
end
