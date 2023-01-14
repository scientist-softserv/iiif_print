module IiifPrint
  # rubocop:disable Metrics/ModuleLength
  module ManifestBuilderServiceBehavior
    def initialize(*args,
                   version: IiifPrint.config.default_iiif_manifest_version,
                   iiif_manifest_factory: iiif_manifest_factory_for(version),
                   &block)
      super(*args, iiif_manifest_factory: iiif_manifest_factory, &block)
      @version = version.to_i
      @presenter_solr_docs = {}
    end

    def manifest_for(presenter:, current_ability:)
      @current_ability = current_ability
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

      send("sanitize_v#{@version}", manifest: hash, presenter: presenter)
    end

    # rubocop:disable Metrics/MethodLength
    def sanitize_v2(manifest:, presenter:)
      manifest['label'] = CGI.unescapeHTML(sanitize_value(manifest['label'])) if manifest.key?('label')
      manifest.delete('description') # removes default description since it's in the metadata fields
      manifest['sequences']&.each do |sequence|
        sequence['canvases']&.each do |canvas|
          canvas['label'] = CGI.unescapeHTML(sanitize_value(canvas['label']))
          apply_v2_metadata_to_canvas(canvas: canvas, presenter: presenter)
        end
      end

      sort_hash_by_identifier!(manifest)
      manifest
    end
    # rubocop:enable Metrics/MethodLength

    def sanitize_v3(manifest:, presenter:)
      # TODO: flesh out metadata for v3
      manifest
    end

    def apply_v2_metadata_to_canvas(canvas:, presenter:)
      solr_docs = get_solr_docs(presenter)
      # uses the '@id' property which is a URL that contains the FileSet id
      file_set_id = canvas['@id'].split('/').last
      # finds the image that the FileSet is attached to and creates metadata on that canvas
      image = solr_docs.find do |doc|
        # TODO: filter out has_model_ssim FileSet in #get_solr_docs
        doc[:member_ids_ssim]&.include?(file_set_id) && doc[:has_model_ssim] != ["FileSet"]
      end
      canvas_metadata = IiifPrint.manifest_metadata_for(model: image, current_ability: @current_ability)
      canvas['metadata'] = canvas_metadata
    end

    def sort_hash_by_identifier!(hash)
      hash["sequences"]&.first&.[]("canvases")&.sort_by! do |canvas|
        selection = canvas["metadata"].select { |h| h["label"] == "Identifier" }
        fallback = [{ label: "Identifier", value: ['~'] }]
        identifier_metadata = selection.presence || fallback
        identifier_metadata.first["value"] if identifier_metadata.present?
      end
    end

    def get_solr_docs(presenter)
      @presenter_solr_docs[presenter.id] ||= begin
        parent_id = [presenter._source['id']]
        child_ids = presenter._source['member_ids_ssim']
        parent_id_and_child_ids = parent_id + child_ids
        # TODO: filter out has_model_ssim FileSet
        query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(parent_id_and_child_ids)
        solr_hits = ActiveFedora::SolrService.query(query, rows: 100_000)
        solr_hits.map { |solr_hit| ::SolrDocument.new(solr_hit) }
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
end
