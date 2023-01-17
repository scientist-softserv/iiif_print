module IiifPrint
  class Metadata
    def self.build_metadata_for(work:, version:, fields:, current_ability:, base_url:)
      new(work: work,
          version: version,
          fields: fields,
          current_ability: current_ability,
          base_url: base_url).build_metadata
    end

    def initialize(work:, version:, fields:, current_ability:, base_url:)
      @work = work
      @version = version.to_i
      @fields = fields
      @current_ability = current_ability
      @base_url = base_url
    end

    attr_reader :work, :version, :fields

    def build_metadata
      send("build_metadata_for_v#{version}")
    end

    private

    def build_metadata_for_v2
      fields.map do |field|
        label = Hyrax::Renderers::AttributeRenderer.new(field.name, nil).label
        if field.name == :collection && member_of_collection?
          viewable_collections = Hyrax::CollectionMemberService.run(work, @current_ability)
          next if viewable_collections.empty?
          { 'label' => label,
            'value' => make_collection_link(viewable_collections) }
        else
          next if field_is_empty?(field)
          { 'label' => label,
            'value' => cast_to_value(field_name: field.name, options: field.options) }
        end
      end.compact
    end

    def build_metadata_for_v3
      fields.map do |field|
        values = Array(work.try(field.name)).map { |value| scrub(value.to_s) }
        next if values.empty?
        {
          'label' => {
            # Since we're using I18n to translate the field, we're setting the locale used in the translation.
            I18n.locale.to_s => [Hyrax::Renderers::AttributeRenderer.new(field.name, nil).label]
          },
          'value' => {
            'none' => values
          }
        }
      end.compact
    end

    def field_is_empty?(field)
      Array(work.try(field.name)).empty?
    end

    def member_of_collection?
      work[:member_of_collection_ids_ssim]&.present?
    end

    def scrub(value)
      Loofah.fragment(value).scrub!(:whitewash).to_s
    end

    def cast_to_value(field_name:, options:)
      if options&.[](:render_as) == :faceted
        Array(work.send(field_name)).map do |value|
          search_field = field_name.to_s + "_sim"
          path = Rails.application.routes.url_helpers.search_catalog_path(
            "f[#{search_field}][]": value, locale: I18n.locale
          )
          path += '&include_child_works=true' if work["is_child_bsi"] == true
          "<a href='#{@base_url}#{path}'>#{value}</a>"
        end
      else
        make_link(work.send(field_name))
      end
    end

    def make_collection_link(collection_documents)
      collection_documents.map do |collection|
        "<a href='#{@base_url}/collections/#{collection.id}'>#{collection.title.first}</a>"
      end
    end

    # @note This method turns link looking strings into links
    def make_link(text)
      Array(text).map do |t|
        t.to_s.gsub(MAKE_LINK_REGEX) do |url|
          "<a href='#{url}' target='_blank'>#{url}</a>"
        end
      end
    end

    MAKE_LINK_REGEX = %r{
      \b
      (
        (?: [a-z][\w-]+:
          (?: /{1,3} | [a-z0-9%] ) |
            www\d{0,3}[.] |
            [a-z0-9.\-]+[.][a-z]{2,4}/
        )
        (?:
          [^\s()<>]+ | \(([^\s()<>]+|(\([^\s()<>]+\)))*\)
        )+
        (?:
          \(([^\s()<>]+|(\([^\s()<>]+\)))*\) |
          [^\s`!()\[\]{};:'".,<>?«»〝〞‘‛]
        )
      )
    }ix.freeze
  end
end
