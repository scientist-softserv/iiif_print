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

    attr_writer :models_to_be_excluded_from_search
    def models_to_be_excluded_from_search
      return @models_to_be_excluded_from_search unless @models_to_be_excluded_from_search.nil?
      @models_to_be_excluded_from_search = []
    end

    attr_writer :name_for_model
    def name_for_model
      return "human_readable_type" unless defined?(@name_for_model)
      @name_for_model
    end

    attr_writer :solr_field_name_for_model
    def solr_field_name_for_model
      return "#{name_for_model}_sim" unless defined?(@solr_field_name_for_model)
      @solr_field_name_for_model
    end
  end
end
