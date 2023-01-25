module IiifPrint
  module CatalogControllerDecorator
    # rubocop:disable Metrics/MethodLength
    def iiif_search
      _parent_response, @parent_document = fetch(params[:solr_document_id])
      iiif_search = ::BlacklightIiifSearch::IiifSearch.new(iiif_search_params, iiif_search_config,
                                                         @parent_document)
      @response, _document_list = search_results(iiif_search.solr_params)
      iiif_search_response = ::BlacklightIiifSearch::IiifSearchResponse.new(@response,
                                                                            @parent_document,
                                                                            self)
      json_results = iiif_search_response.annotation_list
      json_results&.[]('resources')&.each do |result_hit|
        next if result_hit['resource'].present?
        result_hit['resource'] = {
          "@type": "cnt:ContentAsText",
          "chars": "Metadata match, see sidebar for details"
        }
      end

      render json: json_results,
             content_type: 'application/json'
    end
  end
  # rubocop:enable Metrics/MethodLength
end
