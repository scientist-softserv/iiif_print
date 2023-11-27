# frozen_string_literal: true

# SearchBuilder for full-text searches with highlighting and snippets
class IiifSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include IiifPrint::AllinsonFlexFields

  self.default_processor_chain += %i[ocr_search_params include_allinson_flex_fields]

  # set params for ocr field searching
  def ocr_search_params(solr_parameters = {})
    solr_parameters[:facet] = false
    solr_parameters[:hl] = true
    solr_parameters[:'hl.fl'] = blacklight_config.iiif_search[:full_text_field]
    solr_parameters[:'hl.fragsize'] = 100
    solr_parameters[:'hl.snippets'] = 10
  end
end
