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
      # @param work_type [Class<ActiveFedora::Base>]
      # @return form for the given :work_type
      def self.decorate_form_with_adapter_logic(work_type:)
        form = "#{work_type}Form".constantize
        form.send(:include, Hyrax::FormFields(:child_works_from_pdf_splitting)) unless form.included_modules.include?(Hyrax::FormFields(:child_works_from_pdf_splitting))
        form
      end

      ##
      # Return the immediate parent of the given :file_set.
      #
      # @param file_set [Hyrax::FileMetadata or FileSet]
      # @return [#work?, Hydra::PCDM::Work]
      # @return [NilClass] when no parent is found.
      def self.parent_for(file_set)
        file_set = Hyrax.query_service.find_by(id: file_set.file_set_id) if file_set.is_a?(Hyrax::FileMetadata)
        Hyrax.query_service.find_parents(resource: file_set).first
      end

      ##
      # Return the parent's parent of the given :file_set.
      #
      # @param file_set [Hyrax::FileMetadata or FileSet]
      # @return [#work?, Hydra::PCDM::Work]
      # @return [NilClass] when no grand parent is found.
      def self.grandparent_for(file_set)
        parent = parent_for(file_set)
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

      # rubocop:disable Lint/UnusedMethodArgument
      def self.destroy_children_split_from(file_set:, work:, model:, user:)
        # rubocop:enable Lint/UnusedMethodArgument
        # look for child records by the file set id they were split from
        Hyrax.query_service.find_inverse_references_by(resource: file_set, property: :split_from_pdf_id, model: model).each do |child|
          Hyrax.persister.delete(resource: child)
          Hyrax.indexing_service.delete(resource: child)
          Hyrax.publisher.publish('object.deleted', object: child, user: user)
        end
        true
      end

      def self.pdf?(file_set)
        file_set.original_file.pdf?
      end

      ##
      # Add a child record as a member of a parent record
      # 
      # @param model [child_record] a Valkyrie::Resource model
      # @param model [parent_record] a Valkyrie::Resource model
      # @return [TrueClass]
      def self.create_relationship_between(child_record:, parent_record:)
        return true if parent_record.member_ids.include?(child_record.id)
        parent_record.member_ids << child_record.id
        true
      end

      ##
      # find a work by title
      # We should only find one, but there is no guarantee of that
      # @param title [String]
      # @param model [String] a Valkyrie::Resource model
      # @return [Array<Valkyrie::Resource]
      def self.find_by_title_for(title:, model:)
        work_type = model.constantize
        # TODO: This creates a hard dependency on Bulkrax because that is where this custom query is defined
        #       Is this adequate?
        Array.wrap(Hyrax.query_service.custom_query.find_by_model_and_property_value(model: work_type,
                                                                                     property: :title,
                                                                                     value: title))
      end

      ##
      # find a work or file_set
      #
      # @param id [String]
      def self.find_by(id:)
        Hyrax.query_service.find_by(id: id)
      end

      ##
      # save a work
      #
      # @param object [Array<Valkyrie::Resource]
      def self.save(object:)
        Hyrax.persister.save(resource: object)
        Hyrax.index_adapter.save(resource: object)

        Hyrax.publisher.publish('object.membership.updated', object: object, user: object.depositor)
      end

      ##
      # reindex an array of works and their file_sets
      #
      # @param objects [Array<Valkyrie::Resource]
      # @return [TrueClass]
      def self.index_works(objects:)
        objects.each do |work|
          Hyrax.index_adapter.save(resource: work)
          Hyrax.custom_queries.find_child_file_sets(resource: work).each do |file_set|
            Hyrax.index_adapter.save(resource: file_set)
          end
        end
        true
      end
    end
  end
end
