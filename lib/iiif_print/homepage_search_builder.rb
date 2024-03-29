# frozen_string_literal: true

# Overrides Hyrax to add show_parents_only to processor chain
module IiifPrint
  class HomepageSearchBuilder < Hyrax::HomepageSearchBuilder
    self.default_processor_chain += [:show_parents_only]

    def show_parents_only(solr_parameters)
      query = if blacklight_params["include_child_works"] == 'true'
                IiifPrint.solr_construct_query(is_child_bsi: 'true')
              else
                IiifPrint.solr_construct_query(is_child_bsi: nil)
              end
      solr_parameters[:fq] += [query]
    end
  end
end
