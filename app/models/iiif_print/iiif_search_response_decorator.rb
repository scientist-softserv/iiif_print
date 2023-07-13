module IiifPrint
  module IiifSearchResponseDecorator
    # Enable the user to search for child metadata in the parent's UV
    # @see https://github.com/scientist-softserv/louisville-hyku/commit/67467e5cf9fdb755f54419f17d3c24c87032d0af
    def annotation_list
      json_results = super

      # Break down the json_results for easy access
      resources = json_results['resources']
      hits = json_results['hits']
      within = json_results['within']

      # Check and process invalid hit
      if resources
        remove_invalid_hit(resources, hits, within)
        add_metadata_match(resources)
      end

      json_results
    end

    def remove_invalid_hit(resources, hits, within)
      invalid_hit = resources.detect { |resource| resource["on"].include?(IiifPrint::BlacklightIiifSearch::AnnotationDecorator::INVALID_MATCH_TEXT) }
      return unless invalid_hit

      # Delete invalid hit from resources, remove first hit (which is from the invalid hit), decrement total within
      resources.delete(invalid_hit)
      hits.shift
      within['total'] -= 1
    end

    def add_metadata_match(resources)
      resources.each do |result_hit|
        next if result_hit['resource'].present?

        # Add resource details if not present
        result_hit['resource'] = {
          "@type": "cnt:ContentAsText",
          "chars": "Metadata match, see sidebar for details"
        }
      end
    end
  end
end
