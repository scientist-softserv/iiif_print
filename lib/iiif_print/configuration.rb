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

    attr_writer :excluded_model_names
    # By default, this uses an array of human readable types
    #   ex: [GenericWork, Image]
    # @return [Array<String>]
    def excluded_model_names
      return @excluded_model_names unless @excluded_model_names.nil?
      @excluded_model_names = []
    end
  end
end
