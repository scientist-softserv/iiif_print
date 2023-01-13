# mixin to provide URL for IIIF Content Search service
module IiifPrint
  module IiifManifestPresenterBehavior
    extend ActiveSupport::Concern

    def search_service
      Rails.application.routes.url_helpers.solr_document_iiif_search_url(id, host: hostname)
    end

    # based on Hyrax::WorkShowPresenter#manifest_metadata
    # expects that individual presenters define #iiif_metadata_fields
    # def manifest_metadata
    #   fields = iiif_metadata_fields || []
    #   metadata = []
    #   fields.each do |field|
    #     label = Hyrax::Renderers::AttributeRenderer.new(field, nil).label
    #     value = send(field)
    #     next if value.blank?
    #     value = Array.wrap(value) if value.is_a?(String)
    #     metadata << {
    #       'label' => label,
    #       'value' => Array.wrap(value.map { |f| Loofah.fragment(f.to_s).scrub!(:whitewash).to_s })
    #     }
    #   end
    #   metadata
    # end
  end
end
