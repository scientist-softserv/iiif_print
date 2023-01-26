# customize behavior for IiifSearch
module IiifPrint
  module BlacklightIiifSearch
    module SearchBehavior
      ##
      # params to limit the search to items that are children of item
      # modified to make search field conditional on parent object class
      #
      # @todo Review this method.  It's likely needing some reconsidering and review of the
      #       iiif_config for the given model.
      #
      # @return [Hash]
      def object_relation_solr_params
        parent_model = parent_document['has_model_ssim'].find do |v|
          v.include?('Newspaper')
        end
        solr_field_for_search = case parent_model
                                when 'NewspaperPage'
                                  'id'
                                when 'NewspaperIssue'
                                  'issue_id_ssi'
                                else
                                  iiif_config[:object_relation_field]
                                end
        { solr_field_for_search => id }
      end
    end
  end
end
