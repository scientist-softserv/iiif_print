# mixin to provide URL for IIIF Content Search service
module IiifPrint
  module IiifManifestPresenterBehavior
    extend ActiveSupport::Concern

    def manifest_metadata
      @manifest_metadata ||= IiifPrint.manifest_metadata_from(work: model, presenter: self)
    end

    def search_service
      Rails.application.routes.url_helpers.solr_document_iiif_search_url(id, host: hostname)
    end
  end
end
