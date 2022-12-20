module IiifPrint
  # hide Title, Container, and Issue objects if this is a keyword search
  # can be added to default_processor_chain in a SearchBuilder class
  module ExcludeModels
    extend ActiveSupport::Concern

    def exclude_models(solr_parameters)
      return unless solr_parameters[:q] || solr_parameters[:all_fields]

      solr_parameters[:fq] ||= []
      IiifPrint.config.excluded_model_names.each do |value|
        solr_parameters[:fq] << "-has_model_ssim:\"#{value}\""
      end
    end
  end
end
