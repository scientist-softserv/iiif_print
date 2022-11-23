module IiifPrint
  # hide Title, Container, and Issue objects if this is a keyword search
  # can be added to default_processor_chain in a SearchBuilder class
  module ExcludeModels
    extend ActiveSupport::Concern

    def exclude_models(solr_parameters)
      return unless solr_parameters[:q] || solr_parameters[:all_fields]
      type_field = 'human_readable_type_sim'
      solr_parameters[:fq] ||= []
      %w[Title Container Issue].each do |model|
        solr_parameters[:fq] << '-' + type_field + ':"Newspaper ' + model + '"'
      end
    end
  end
end
