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

    attr_writer :model_name_solr_field_values
    def model_name_solr_field_values
      return @model_name_solr_field_values unless @model_name_solr_field_values.nil?
      @model_name_solr_field_values = []
    end

    attr_writer :model_name_solr_field_key
    def model_name_solr_field_key
      return "human_readable_type_sim" unless defined?(@model_name_solr_field_key)
      @model_name_solr_field_key
    end
  end
end
