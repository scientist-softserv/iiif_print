module IiifPrint
  class Configuration
    attr_writer :models_to_be_excluded_from_search
    def models_to_be_excluded_from_search
      return @models_to_be_excluded_from_search unless @models_to_be_excluded_from_search.nil?
      @models_to_be_excluded_from_search = []
    end
  end
end
