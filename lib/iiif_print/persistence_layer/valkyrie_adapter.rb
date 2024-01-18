module IiifPrint
  module PersistenceLayer
    class ValkyrieAdapter < AbstractAdapter
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
    end
  end
end
