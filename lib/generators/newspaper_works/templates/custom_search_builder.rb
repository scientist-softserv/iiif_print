# custom SearchBuilder that adds BlacklightAdvancedSearch to Hyrax::CatalogSearchBuilder
class CustomSearchBuilder < Hyrax::CatalogSearchBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr,
                                   :fulltext_search_params]

  # add logic to BlacklightAdvancedSearch::AdvancedSearchBuilder
  # so that date range params are recognized as advanced search
  # rubocop:disable Naming/PredicateName
  def is_advanced_search?
    blacklight_params[:date_start].present? || blacklight_params[:date_end].present? || super
  end
  # rubocop:enable Naming/PredicateName

  # add highlights on full text field, if there is a keyword query
  def fulltext_search_params(solr_parameters = {})
    return unless solr_parameters[:q] || solr_parameters[:all_fields]
    solr_parameters[:hl] = true
    solr_parameters[:'hl.fl'] = 'all_text_tsimv'
    solr_parameters[:'hl.fragsize'] = 100
    solr_parameters[:'hl.snippets'] = 5
  end
end
