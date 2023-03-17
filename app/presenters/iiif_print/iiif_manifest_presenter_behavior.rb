# mixin to provide URL for IIIF Content Search service
module IiifPrint
  module IiifManifestPresenterBehavior
    extend ActiveSupport::Concern

    def manifest_metadata
      current_ability = try(:ability) || try(:current_ability)
      base_url = try(:base_url) || try(:request)&.base_url
      @metadata ||= IiifPrint.manifest_metadata_for(work: model, current_ability: current_ability, base_url: base_url)
    end

    def search_service
      Rails.application.routes.url_helpers.solr_document_iiif_search_url(id, host: hostname)
    end
  end
end
