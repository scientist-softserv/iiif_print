module IiifPrint
  class Configuration
    # 'publication_unique_id' configs used for Chronicling America style linking
    # attr_writer :publication_unique_id_property
    # def publication_unique_id_property
    #   @publication_unique_id_property || :lccn
    # end

    ##
    # @param value [Array<Class>]
    attr_writer :work_types_for_derivative_service
    # An array of work types that PageDerivativeService should run on
    # @return [Array]
    def work_types_for_derivative_service
      return @work_types_for_derivative_service unless @work_types_for_derivative_service.nil?
      @work_types_for_derivative_service = []
    end
  end
end
