module IiifPrint
  # hide Title, Container, and Issue objects if this is a keyword search
  # can be added to default_processor_chain in a SearchBuilder class
  module ExcludeModels
    extend ActiveSupport::Concern

    def exclude_models(solr_parameters)
      return unless solr_parameters[:q] || solr_parameters[:all_fields]

      solr_parameters[:fq] ||= []
      key = IiifPrint.config.excluded_model_name_solr_field_key
      IiifPrint.config.excluded_model_name_solr_field_values.each do |value|
        solr_parameters[:fq] << "-#{key}:\"#{value}\""
      end
    end
  end
end
