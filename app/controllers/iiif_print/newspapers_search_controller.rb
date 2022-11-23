# based heavily on BlacklightAdvancedSearch::AdvancedController
module IiifPrint
  class NewspapersSearchController < CatalogController
    def search_builder_class
      IiifPrint::NewspapersSearchBuilder
    end

    def search
      @response = newspaper_search_facets
    end

    private

    # we need this for proper routing of search forms/links
    def search_action_url(*args)
      main_app.search_catalog_url(*args)
    end

    def newspaper_search_facets
      response, = search_results(params) do |search_builder|
        search_builder.except(:add_advanced_search_to_solr)
      end
      response
    end
  end
end
