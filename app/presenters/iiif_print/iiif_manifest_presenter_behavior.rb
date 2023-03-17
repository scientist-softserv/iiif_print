# mixin to provide URL for IIIF Content Search service
module IiifPrint
  module IiifManifestPresenterBehavior
    extend ActiveSupport::Concern

    def manifest_metadata
      @manifest_metadata ||= IiifPrint.manifest_metadata_from(work: model, presenter: self)
    end

    def search_service
      Rails.application.routes.url_helpers.solr_document_iiif_search_url(id, host: hostname)
    end

    # OVERRIDE Hyrax 3x, avoid nil returning to IIIF Manifest gem
    # @see https://github.com/samvera/iiif_manifest/blob/c408f90eba11bef908796c7236ba6bcf8d687acc/lib/iiif_manifest/v3/manifest_builder/record_property_builder.rb#L28
    ##
    # @return [Array<Hash{String => String}>]
    def sequence_rendering
      Array(try(:rendering_ids)).map do |file_set_id|
        rendering = file_set_presenters.find { |p| p.id == file_set_id }
        return [] unless rendering

        { '@id' => Hyrax::Engine.routes.url_helpers.download_url(rendering.id, host: hostname),
          'format' => rendering.mime_type.presence || I18n.t("hyrax.manifest.unknown_mime_text"),
          'label' => I18n.t("hyrax.manifest.download_text") + (rendering.label || '') }
      end.flatten
    end
  end
end
