require 'active_fedora'
require 'hyrax'
require 'blacklight_iiif_search'
require 'derivative_rodeo'

module IiifPrint
  # module constants:
  GEM_PATH = Gem::Specification.find_by_name("iiif_print").gem_dir

  # Engine Class
  class Engine < ::Rails::Engine
    isolate_namespace IiifPrint

    config.eager_load_paths += %W[#{config.root}/app/transactions]

    initializer 'requires' do
      require 'hyrax/transactions/iiif_print_container_decorator'
      require 'iiif_print/persistence_layer'
      require 'iiif_print/persistence_layer/active_fedora_adapter' if defined?(ActiveFedora)
      require 'iiif_print/persistence_layer/valkyrie_adapter' if defined?(Valkyrie)
    end

    # rubocop:disable Metrics/BlockLength
    config.to_prepare do
      require "iiif_print/jobs/create_relationships_job"
      # We don't have a hard requirement of Bullkrax but in our experience, lingering on earlier
      # versions can introduce bugs of both Bulkrax and some of the assumptions that we've resolved.
      # Very early versions of Bulkrax do not have VERSION defined
      if defined?(Bulkrax) && !ENV.fetch("SKIP_IIIF_PRINT_BULKRAX_VERSION_REQUIREMENT", false)
        if !defined?(Bulkrax::VERSION) || (Bulkrax::VERSION.to_i < 5)
          raise "IiifPrint does not have a hard dependency on Bulkrax, " \
                "but if you have Bulkrax installed we recommend at least version 5.0.0.  " \
                "To ignore this recommendation please add SKIP_IIIF_PRINT_BULKRAX_VERSION_REQUIREMENT " \
                "to your ENV variables."
        end
      end

      # Inject PluggableDerivativeService ahead of Hyrax default.
      #   This wraps Hyrax default, but allows multiple valid services
      #   to be configured, instead of just the _first_ valid service.
      #
      #   To configure specific services, inject each service, in desired order
      #   to IiifPrint::PluggableDerivativeService.plugins array.

      Hyrax::DerivativeService.services.unshift(
        IiifPrint::PluggableDerivativeService
      )

      Hyrax.publisher.subscribe(IiifPrint::Listener.new) if Hyrax.respond_to?(:publisher)

      Hyrax::IiifManifestPresenter.prepend(IiifPrint::IiifManifestPresenterBehavior)
      Hyrax::IiifManifestPresenter::Factory.prepend(IiifPrint::IiifManifestPresenterFactoryBehavior)
      Hyrax::ManifestBuilderService.prepend(IiifPrint::ManifestBuilderServiceBehavior)
      Hyrax::Renderers::FacetedAttributeRenderer.prepend(Hyrax::Renderers::FacetedAttributeRendererDecorator)
      Hyrax::WorksControllerBehavior.prepend(IiifPrint::WorksControllerBehaviorDecorator)
      "Hyrax::Transactions::Steps::DeleteAllFileSets".safe_constantize&.prepend(Hyrax::Transactions::Steps::DeleteAllFileSetsDecorator)
      # Hyku::WorksControllerBehavior was introduced in Hyku v6.0.0+.  Yes we don't depend on Hyku,
      # but this allows us to do minimal Hyku antics with IiifPrint.
      'Hyku::WorksControllerBehavior'.safe_constantize&.prepend(IiifPrint::WorksControllerBehaviorDecorator)

      Hyrax::FileSetPresenter.prepend(IiifPrint::FileSetPresenterDecorator)
      Hyrax::WorkShowPresenter.prepend(IiifPrint::WorkShowPresenterDecorator)
      Hyrax::IiifHelper.prepend(IiifPrint::IiifHelperDecorator)

      if ActiveModel::Type::Boolean.new.cast(ENV.fetch('HYRAX_VALKYRIE', false))
        # Newer versions of Hyrax favor `Hyrax::Indexers::FileSetIndexer` and deprecate
        # `Hyrax::ValkyrieFileSetIndexer`.
        'Hyrax::Indexers::FileSetIndexer'.safe_constantize&.prepend(IiifPrint::FileSetIndexer)

        # Versions 3.0+ of Hyrax have `Hyrax::ValkyrieFileSetIndexer` so we want to decorate that as
        # well.  We want to use the elsif construct because later on Hyrax::ValkyrieFileSetIndexer
        # inherits from Hyrax::Indexers::FileSetIndexer and only implements:
        # `def initialize(*args); super; end`
        'Hyrax::ValkyrieFileSetIndexer'.safe_constantize&.prepend(IiifPrint::FileSetIndexer)

        # Newer versions of Hyrax favor `Hyrax::Indexers::PcdmObjectIndexer` and deprecate
        # `Hyrax::ValkyrieWorkIndexer`
        indexers = Hyrax.config.curation_concerns.map do |concern|
          "#{concern}ResourceIndexer".safe_constantize
        end
        indexers.each { |indexer| indexer.prepend(IiifPrint::ChildWorkIndexer) }

        # Versions 3.0+ of Hyrax have `Hyrax::ValkyrieWorkIndexer` so we want to decorate that as
        # well.  We want to use the elsif construct because later on Hyrax::ValkyrieWorkIndexer
        # inherits from Hyrax::Indexers::PcdmObjectIndexer and only implements:
        # `def initialize(*args); super; end`
        'Hyrax::ValkyrieWorkIndexer'.safe_constantize&.prepend(IiifPrint::ChildWorkIndexer)
      else
        # The ActiveFedora::Base indexer for FileSets
        Hyrax::FileSetIndexer.prepend(IiifPrint::FileSetIndexer)
        # The ActiveFedora::Base indexer for Works
        Hyrax::WorkIndexer.prepend(IiifPrint::ChildWorkIndexer)
      end

      ::BlacklightIiifSearch::IiifSearchResponse.prepend(IiifPrint::IiifSearchResponseDecorator)
      ::BlacklightIiifSearch::IiifSearchAnnotation.prepend(IiifPrint::BlacklightIiifSearch::AnnotationDecorator)
      ::BlacklightIiifSearch::IiifSearch.prepend(IiifPrint::IiifSearchDecorator)
      Hyrax::Actors::FileSetActor.prepend(IiifPrint::Actors::FileSetActorDecorator)
      Hyrax::Actors::CleanupFileSetsActor.prepend(IiifPrint::Actors::CleanupFileSetsActorDecorator)

      Hyrax.config do |config|
        config.callback.set(:after_create_fileset) do |file_set, user|
          IiifPrint.config.handle_after_create_fileset(file_set, user)
        end
      end
    end

    config.after_initialize do
      IiifPrint::Solr::Document.decorate(SolrDocument)
      Hyrax::IiifManifestPresenter::DisplayImagePresenter
        .prepend(IiifPrint::IiifManifestPresenterBehavior::DisplayImagePresenterBehavior)
    end
    # rubocop:enable Metrics/BlockLength
  end
end
