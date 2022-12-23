module IiifPrint
  class Configuration
    ##
    # @param value [Array<Class>]
    attr_writer :work_types_for_derivative_service
    # An array of work types that PageDerivativeService should run on
    # @return [Array]
    def work_types_for_derivative_service
      return @work_types_for_derivative_service unless @work_types_for_derivative_service.nil?
      @work_types_for_derivative_service = []
    end

    attr_writer :excluded_model_name_solr_field_values
    # By default, this uses an array of human readable types
    #   ex: ['Generic Work', 'Image']
    # @return [Array<String>]
    def excluded_model_name_solr_field_values
      return @excluded_model_name_solr_field_values unless @excluded_model_name_solr_field_values.nil?
      @excluded_model_name_solr_field_values = []
    end

    attr_writer :excluded_model_name_solr_field_key
    # A string of a solr field key
    # @return [String]
    def excluded_model_name_solr_field_key
      return "human_readable_type_sim" unless defined?(@excluded_model_name_solr_field_key)
      @excluded_model_name_solr_field_key
    end

    attr_writer :skip_derivative_service_by_work_type
    def skip_derivative_service_by_work_type
      return @skip_derivative_service_by_work_type unless @skip_derivative_service_by_work_type.nil?
      @skip_derivative_service_by_work_type = {}
    end
  end
end
