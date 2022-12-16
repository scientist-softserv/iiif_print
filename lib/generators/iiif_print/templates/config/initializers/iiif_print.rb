IiifPrint.config do |config|
  # NOTE: WorkTypes and models are used synonymously here.
  #
  # Add WorkTypes into the Array to use PageDerivativeService
  # @example
  #   # config.work_types_for_derivative_service = [GenericWork, Image]
  # config.work_types_for_derivative_service = []

  # Add models to be excluded from search so the user
  # would not see them in the search results
  # @example
  #   # config.model_name_solr_field_values = ['Generic Work']
  # config.model_name_solr_field_values = []

  # Add configurable solr field key for searching, default is:
  # config.model_name_solr_field_key = 'human_readable_type_sim'
end
