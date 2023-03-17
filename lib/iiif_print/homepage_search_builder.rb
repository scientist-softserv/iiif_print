# frozen_string_literal: true
require 'hyrax/homepage_search_builder'

# Overrides Hyrax to add show_parents_only to processor chain
module IiifPrint
  class HomepageSearchBuilder < Hyrax::HomepageSearchBuilder
    include Hyrax::FilterByType
    self.default_processor_chain += [:add_access_controls_to_solr_params, :show_parents_only]

    def only_works?
      true
    end

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
