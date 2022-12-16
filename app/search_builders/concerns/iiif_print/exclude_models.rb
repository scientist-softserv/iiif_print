module IiifPrint
  # hide Title, Container, and Issue objects if this is a keyword search
  # can be added to default_processor_chain in a SearchBuilder class
  module ExcludeModels
    extend ActiveSupport::Concern

    def exclude_models(solr_parameters)
      return unless solr_parameters[:q] || solr_parameters[:all_fields]

      solr_parameters[:fq] ||= []
      solr_field_name = IiifPrint.config.solr_field_name_for_model
      IiifPrint.config.models_to_be_excluded_from_search.each do |model|
        solr_field_value = model.public_send(IiifPrint.config.name_for_model)
        solr_parameters[:fq] << "-#{solr_field_name}:\"#{model}\""
      end
    end
  end
end
