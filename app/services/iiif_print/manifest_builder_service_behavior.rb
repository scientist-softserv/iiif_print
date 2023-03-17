module IiifPrint
  module ManifestBuilderServiceBehavior
    def initialize(*args,
                   version: IiifPrint.config.default_iiif_manifest_version,
                   iiif_manifest_factory: iiif_manifest_factory_for(version),
                   &block)
      super(*args, iiif_manifest_factory: iiif_manifest_factory, &block)
      @version = version.to_i
      @child_works = nil
    end

    attr_reader :child_works

    def manifest_for(presenter:)
      @child_works = get_solr_hits(member_ids_for(presenter))
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
      return send("sort_canvases_v#{@version}", hash: hash, sort_field: IiifPrint.config.sort_iiif_manifest_canvases_by) if @child_works.present?

      hash
    end

    def sanitize_v2(hash:, presenter:)
      hash['label'] = CGI.unescapeHTML(sanitize_value(hash['label'])) if hash.key?('label')
      hash.delete('description') # removes default description since it's in the metadata fields
      hash['sequences']&.each do |sequence|
        sequence['canvases']&.each do |canvas|
          canvas['label'] = CGI.unescapeHTML(sanitize_value(canvas['label']))
          apply_metadata_to_canvas(canvas: canvas, presenter: presenter)
        end
      end
      hash
    end

    def sanitize_v3(hash:, presenter:)
      hash['label']['none'].map! { |text| CGI.unescapeHTML(sanitize_value(text)) } if hash.key('label')
      hash['items'].each do |canvas|
        canvas['label']['none'].map! { |text| CGI.unescapeHTML(sanitize_value(text)) }
        apply_metadata_to_canvas(canvas: canvas, presenter: presenter)
      end
      hash
    end

    def apply_metadata_to_canvas(canvas:, presenter:)
      return if @child_works.empty?

      parent_and_child_solr_hits = parent_and_child_solr_hits(presenter)
      # uses the 'id' property for v3 manifest and `@id' for v2, which is a URL that contains the FileSet id
      file_set_id = (canvas['id'] || canvas['@id']).split('/').last
      # finds the image that the FileSet is attached to and creates metadata on that canvas
      image = parent_and_child_solr_hits.find { |doc| doc[:member_ids_ssim]&.include?(file_set_id) }

      current_ability = presenter.try(:ability) || presenter.try(:current_ability)
      base_url = presenter.try(:base_url) || presenter.try(:request)&.base_url
      canvas_metadata = IiifPrint.manifest_metadata_for(work: image,
                                                        current_ability: current_ability,
                                                        base_url: base_url)
      canvas['metadata'] = canvas_metadata
    end

    LARGEST_SORT_ORDER_CHAR = '~'.freeze

    def sort_canvases_v2(hash:, sort_field:)
      sort_field = Hyrax::Renderers::AttributeRenderer.new(sort_field, nil).label
      hash['sequences']&.first&.[]('canvases')&.sort_by! do |canvas|
        selection = canvas['metadata'].select { |h| h['label'] == sort_field }
        fallback = [{ label: sort_field,
                      value: [LARGEST_SORT_ORDER_CHAR] }]
        sort_field_metadata = selection.presence || fallback
        sort_field_metadata.first['value'] if sort_field_metadata.present?
      end
      hash
    end

    def sort_canvases_v3(hash:, sort_field:)
      sort_field = Hyrax::Renderers::AttributeRenderer.new(sort_field, nil).label
      hash['items']&.sort_by! do |item|
        selection = item['metadata'].select { |h| h['label'][I18n.locale.to_s] == [sort_field] }
        fallback = [{ label: { "#{I18n.locale}": [sort_field] },
                      value: { none: [LARGEST_SORT_ORDER_CHAR] } }]
        sort_field_metadata = selection.presence || fallback
        sort_field_metadata.first['value']['none'] if sort_field_metadata.present?
      end
      hash
    end

    def member_ids_for(presenter)
      member_ids = presenter.try(:ordered_ids) || presenter.try(:member_ids)
      member_ids.nil? ? [] : member_ids
    end

    def parent_and_child_solr_hits(presenter)
      ids = [presenter.id] + member_ids_for(presenter)
      get_solr_hits(ids)
    end

    ##
    # return an array of work SolrHits
    # @param ids [Array]
    # @return [Array<ActiveFedora::SolrHit>]
    def get_solr_hits(ids)
      query = "id:(#{ids.join(' OR ')})"
      ActiveFedora::SolrService.query(query, fq: "-has_model_ssim:FileSet", rows: ids.size)
    end
  end
end
