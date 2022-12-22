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
  #  # config.models_to_be_excluded_from_search = [Attachment]
  # config.models_to_be_excluded_from_search = []

  # Add WorkTypes as keys and services as values (Array if multiple) into
  # the Hash to skip the creation of specific derivatives for that specific
  # key/WorkType.
  # List of services can be found in `lib/iiif_print/engine.rb`.
  #
  # @example
  #  # config.skip_derivative_service_by_work_type = {
  #  #   GenericWork: [:jp2, :tif, :text, :pdf],
  #  #   Image: :text
  #  # }
  # config.skip_derivative_service_by_work_type = {}
end
