module IiifPrint
  module PersistenceLayer
    class ValkyrieAdapter < AbstractAdapter
      ##
      # @param object [Valkyrie::Resource]
      # @return [Array<Valkyrie::Resource>]
      def self.object_in_works(object)
        Array.wrap(Hyrax.custom_queries.find_parent_work(resource: object))
      end

      ##
      # @param object [Valkyrie::Resource]
      # @return [Array<Valkyrie::Resource>]
      def self.object_ordered_works(object)
        child_file_sets = Hyrax.custom_queries.find_child_file_sets(resource: object).to_a
        child_works = Hyrax.custom_queries.find_child_works(resource: object).to_a
        child_works + child_file_sets
      end

      ##
      # @param work_type [Class<Valkyrie::Resource>]
      # @return the indexer for the given :work_type
      def self.decorate_with_adapter_logic(work_type:)
        work_type.send(:include, Hyrax::Schema(:child_works_from_pdf_splitting)) unless work_type.included_modules.include?(Hyrax::Schema(:child_works_from_pdf_splitting))
        # TODO: Use `Hyrax::ValkyrieIndexer.indexer_class_for` once changes are merged.
        indexer = "#{work_type}Indexer".constantize
        indexer.send(:include, Hyrax::Indexer(:child_works_from_pdf_splitting)) unless indexer.included_modules.include?(Hyrax::Indexer(:child_works_from_pdf_splitting))
        indexer
      end

      ##
      # Return the immediate parent of the given :file_set.
      #
      # @param file_set [FileSet]
      # @return [#work?, Hydra::PCDM::Work]
      # @return [NilClass] when no parent is found.
      def self.parent_for(file_set)
        Hyrax.query_service.find_parents(resource: file_set).first
      end

      ##
      # Return the parent's parent of the given :file_set.
      #
      # @param file_set [FileSet]
      # @return [#work?, Hydra::PCDM::Work]
      # @return [NilClass] when no grand parent is found.
      def self.grandparent_for(file_set)
        parent = Hyrax.query_service.find_parents(resource: file_set).first
        return nil unless parent
        Hyrax.query_service.find_parents(resource: parent).first
      end

      def self.solr_construct_query(*args)
        Hyrax::SolrQueryBuilderService.construct_query(*args)
      end

      def self.clean_for_tests!
        # For Fedora backed repositories, we'll want to consider some cleaning mechanism.  For
        # database backed repositories, we can rely on the database_cleaner gem.
        raise NotImplementedError
      end

      def self.solr_query(query, **args)
        Hyrax::SolrService.query(query, **args)
      end

      def self.solr_name(field_name)
        Hyrax.config.index_field_mapper.solr_name(field_name.to_s)
      end

      def self.destroy_children_split_from(file_set:, work:, model:, user:)
        # look first for children by the file set id they were split from
        children = Hyrax.query_service.find_all_of_model(model: model).select { |m| m.split_from_pdf_id == file_set.id }
        if children.blank?
          # find works where file name and work `to_param` are both in the title
          children = Hyrax.query_service.find_all_of_model(model: model).select { |m| m.title.include?(file_set.label) && m.title.include?(work.to_param) }
        end
        return if children.blank?
        children.each do |rcd|
          Hyrax.persister.delete(resource: rcd)
          Hyrax.indexing_service.delete(resource: rcd)
          Hyrax.publisher.publish('object.deleted', object: rcd, user: user)
        end
        true
      end

      def self.pdf?(file_set)
        file_set.original_file.pdf?
      end
    end
  end
end
