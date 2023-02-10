require 'hyrax/catalog_search_builder'

module IiifPrint
  # This class extends the base Hyrax::CatalogSearchBuilder by:
  #
  # - supporting highlighting of snippets in results
  # - excluding models from search result; with complex works you might want to skip some of those
  #   works.
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    # TODO: Do we need the following as a module?  It hides the behavior
    include IiifPrint::HighlightSearchParams
    # TODO: Do we need the following as a module?  It hides the behavior
    include IiifPrint::ExcludeModels

    # NOTE: If you are using advanced_search, the :exclude_models and :highlight_search_params must
    # be added after the advanced_search methods (which are not part of this gem).  In other tests,
    # we found that having the advanced search processing after the two aforementioned processors
    # resulted in improper evaluation of keyword querying.
    self.default_processor_chain += [:exclude_models, :highlight_search_params, :show_parents_only]

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
