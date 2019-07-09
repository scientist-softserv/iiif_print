module NewspaperWorks
  # add highlighting on _stored_ full text field if this is a keyword search
  # can be added to default_processor_chain in a SearchBuilder class
  module HighlightSearchParams

    # add highlights on full text field, if there is a keyword query
    def highlight_search_params(solr_parameters = {})
      return unless solr_parameters[:q] || solr_parameters[:all_fields]
      solr_parameters[:hl] = true
      solr_parameters[:'hl.fl'] = 'all_text_tsimv'
      solr_parameters[:'hl.fragsize'] = 100
      solr_parameters[:'hl.snippets'] = 5
    end
  end
end
