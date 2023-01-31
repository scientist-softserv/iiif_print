module IiifPrint
  module IiifSearchResponseDecorator
    # Enable the user to search for child metadata in the parent's UV
    # @see https://github.com/scientist-softserv/louisville-hyku/commit/67467e5cf9fdb755f54419f17d3c24c87032d0af
    def annotation_list
      json_results = super
      json_results&.[]('resources')&.each do |result_hit|
        next if result_hit['resource'].present?
        result_hit['resource'] = {
          "@type": "cnt:ContentAsText",
          "chars": "Metadata match, see sidebar for details"
        }
      end
      json_results
    end
  end
end
