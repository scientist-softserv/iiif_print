require 'active_fedora'
require 'hyrax'

module NewspaperWorks
  # module constants:
  GEM_PATH = Gem::Specification.find_by_name("newspaper_works").gem_dir

  # Engine Class
  class Engine < ::Rails::Engine
    isolate_namespace NewspaperWorks

    config.to_prepare do
      # Inject PluggableDerivativeService ahead of Hyrax default.
      #   This wraps Hyrax default, but allows multiple valid services
      #   to be configured, instead of just the _first_ valid service.
      #
      #   To configure specific services, inject each service, in desired order
      #   to NewspaperWorks::PluggableDerivativeService.plugins array.

      Hyrax::DerivativeService.services.unshift(
        NewspaperWorks::PluggableDerivativeService
      )

      # Register specific derivative services to be considered by
      #   PluggableDerivativeService:
      [
        NewspaperWorks::JP2DerivativeService,
        NewspaperWorks::PDFDerivativeService,
        NewspaperWorks::TextExtractionDerivativeService,
        NewspaperWorks::TIFFDerivativeService
      ].each do |plugin|
        NewspaperWorks::PluggableDerivativeService.plugins.push plugin
      end

      # Register actor to handle any NewspaperWorks upload behaviors before
      #   CreateWithFilesActor gets to them:
      Hyrax::CurationConcern.actor_factory.insert_before Hyrax::Actors::CreateWithFilesActor, NewspaperWorks::Actors::NewspaperWorksUploadActor
    end
  end
end
