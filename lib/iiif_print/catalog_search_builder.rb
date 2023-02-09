require 'hyrax/catalog_search_builder'

module IiifPrint
  # This class extends the base Hyrax::CatalogSearchBuilder by:
  #
  # - supporting highlighting of snippets in results
  # - excluding models from search result; with complex works you might want to skip some of those
  #   works.
  # - BlacklightAdvancedSearch::AdvancedSearchBuilder, to support /newspapers_search
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    # TODO: Do we need the following as a module?  It hides the behavior
    include IiifPrint::HighlightSearchParams
    # TODO: Do we need the following as a module?  It hides the behavior
    include IiifPrint::ExcludeModels

    # :exclude_models and :highlight_search_params must be added after advanced_search
    #   so keyword query input can be properly eval'd
    self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr,
                                     :exclude_models, :highlight_search_params, :show_parents_only]

    # add logic to BlacklightAdvancedSearch::AdvancedSearchBuilder
    # so that date range params are recognized as advanced search
    # rubocop:disable Naming/PredicateName
    def is_advanced_search?
      blacklight_params[:date_start].present? || blacklight_params[:date_end].present? || super
    end

    # rubocop:enable Naming/PredicateName
    def show_parents_only(solr_parameters)
      query = if blacklight_params["include_child_works"] == 'true'
                ActiveFedora::SolrQueryBuilder.construct_query(is_child_bsi: 'true')
              else
                ActiveFedora::SolrQueryBuilder.construct_query(is_child_bsi: nil)
              end
      solr_parameters[:fq] += [query]
    end
  end
end
