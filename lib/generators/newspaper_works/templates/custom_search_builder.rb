# custom SearchBuilder that adds BlacklightAdvancedSearch to Hyrax::CatalogSearchBuilder
class CustomSearchBuilder < Hyrax::CatalogSearchBuilder
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]

  # add logic to BlacklightAdvancedSearch::AdvancedSearchBuilder
  # so that date range params are recognized as advanced search
  def is_advanced_search?
    blacklight_params[:date_start].present? || blacklight_params[:date_end].present? || super
  end
end
