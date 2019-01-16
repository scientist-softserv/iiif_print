# mixin to provide URL for IIIF Content Search service
module NewspaperWorks
  module IiifSearchPresenterBehavior
    extend ActiveSupport::Concern

    def search_service
      Rails.application.routes.url_helpers.solr_document_iiif_search_url(id,
                                                                         host: request.base_url)
    end
  end
end
