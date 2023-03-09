module IiifPrint
  module ManifestBuilderServiceBehavior
    def initialize(*args,
                   version: IiifPrint.config.default_iiif_manifest_version,
                   iiif_manifest_factory: iiif_manifest_factory_for(version),
                   &block)
      super(*args, iiif_manifest_factory: iiif_manifest_factory, &block)
      @version = version.to_i
    end

    def manifest_for(presenter:)
      build_manifest(presenter: presenter)
    end

    private

    VERSION_TO_MANIFEST_FACTORY_MAP = {
      2 => ::IIIFManifest::ManifestFactory,
      3 => ::IIIFManifest::V3::ManifestFactory
    }.freeze

    def iiif_manifest_factory_for(version)
      VERSION_TO_MANIFEST_FACTORY_MAP.fetch(version.to_i)
    end

    ##
    # Allows for the display of metadata for child works in UV
    #
    # @see https://github.com/samvera/hyrax/blob/main/app/services/hyrax/manifest_builder_service.rb
    def build_manifest(presenter:)
      # ::IIIFManifest::ManifestBuilder#to_h returns a
      # IIIFManifest::ManifestBuilder::IIIFManifest, not a Hash.
      # to get a Hash, we have to call its #to_json, then parse.
      #
      # wild times. maybe there's a better way to do this with the
      # ManifestFactory interface?
      manifest = manifest_factory.new(presenter).to_h
      hash = JSON.parse(manifest.to_json)
      hash = send("sanitize_v#{@version}", hash: hash, presenter: presenter)
      send("sorted_canvases_v#{@version}", hash: hash, sort_field: IiifPrint.config.sort_iiif_manifest_canvases_by)
    end

    def sanitize_v2(hash:, presenter:)
      hash['label'] = CGI.unescapeHTML(sanitize_value(hash['label'])) if hash.key?('label')
      hash.delete('description') # removes default description since it's in the metadata fields
      hash['sequences']&.each do |sequence|
        sequence['canvases']&.each do |canvas|
          canvas['label'] = CGI.unescapeHTML(sanitize_value(canvas['label']))
          apply_v2_metadata_to_canvas(canvas: canvas, presenter: presenter)
        end
      end
      hash
    end

    def sanitize_v3(hash:, **)
      # TODO: flesh out metadata for v3
      hash
    end

    def apply_v2_metadata_to_canvas(canvas:, presenter:)
      solr_docs = get_solr_docs(presenter)
      # uses the '@id' property which is a URL that contains the FileSet id
      file_set_id = canvas['@id'].split('/').last
      # finds the image that the FileSet is attached to and creates metadata on that canvas
      image = solr_docs.find { |doc| doc[:member_ids_ssim]&.include?(file_set_id) }
      canvas_metadata = IiifPrint.manifest_metadata_for(work: image,
                                                        current_ability: presenter.try(:ability) || presenter.try(:current_ability),
                                                        base_url: presenter.try(:base_url) || presenter.try(:request)&.base_url)
      canvas['metadata'] = canvas_metadata
    end

    def sorted_canvases_v2(hash:, sort_field:)
      sort_field = Hyrax::Renderers::AttributeRenderer.new(sort_field, nil).label
      hash["sequences"]&.first&.[]("canvases")&.sort_by! do |canvas|
        selection = canvas["metadata"].select { |h| h["label"] == sort_field }
        fallback = [{ label: sort_field, value: ['~'] }]
        identifier_metadata = selection.presence || fallback
        identifier_metadata.first["value"] if identifier_metadata.present?
      end
      hash
    end

    def sorted_canvases_v3(hash:, **)
      # TODO: flesh out metadata for v3
      hash
    end

    def get_solr_docs(presenter)
      parent_id = presenter.id
      child_ids = presenter.try(:member_ids) || presenter.try(:ordered_ids)
      parent_id_and_child_ids = child_ids << parent_id
      query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(parent_id_and_child_ids)
      solr_hits = ActiveFedora::SolrService.query(query, fq: "-has_model_ssim:FileSet", rows: 100_000)
      solr_hits.map { |solr_hit| ::SolrDocument.new(solr_hit) }
    end
  end
end
