require 'active_fedora'
require 'hyrax'
require 'blacklight_iiif_search'
require 'blacklight_advanced_search'

module IiifPrint
  # module constants:
  GEM_PATH = Gem::Specification.find_by_name("iiif_print").gem_dir

  # Engine Class
  class Engine < ::Rails::Engine
    isolate_namespace IiifPrint

    config.to_prepare do
      # Inject PluggableDerivativeService ahead of Hyrax default.
      #   This wraps Hyrax default, but allows multiple valid services
      #   to be configured, instead of just the _first_ valid service.
      #
      #   To configure specific services, inject each service, in desired order
      #   to IiifPrint::PluggableDerivativeService.plugins array.

      Hyrax::DerivativeService.services.unshift(
        IiifPrint::PluggableDerivativeService
      )

      # Register actor to handle any IiifPrint upload behaviors before
      #   CreateWithFilesActor gets to them:
      Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::CreateWithFilesActor, IiifPrint::Actors::IiifPrintUploadActor
      Hyrax::IiifManifestPresenter.prepend(IiifPrint::IiifManifestPresenterBehavior)
      Hyrax::IiifManifestPresenter::Factory.prepend(IiifPrint::IiifManifestPresenterFactoryBehavior)
      Hyrax::ManifestBuilderService.prepend(IiifPrint::ManifestBuilderServiceBehavior)
    end
  end
end
