module IiifPrint
  # rubocop:disable Metrics/ModuleLength, Metrics/ClassLength
  class Metadata
    def self.manifest_for(model:, version:, fields:)
      new(model: model, version: version, fields: fields).manifest
    end

    def initialize(model:, version:, fields:)
      @model = model
      @version = version
      @fields = fields
    end

    attr_reader :model, :version, :fields

    # rubocop:disable MethodLength, CyclomaticComplexity, PerceivedComplexity, AbcSize
    def manifest
      case version
      when 2
        fields.map do |field|
          options = field.options
          parent = model.try(:model)
          next if parent
          label = Hyrax::Renderers::AttributeRenderer.new(field.name, nil).label
          if field.name == :collection
            next unless model[:member_of_collection_ids_ssim]&.present?
            viewable_collections = Hyrax::CollectionMemberService.run(model, @current_ability)
            next if viewable_collections.blank?
            {
              'label' => label,
              'value' => make_collection_link(viewable_collections)
            }
          else
            next if Array(model.try(field.name)).first.blank?
            {
              'label' => label,
              'value' => cast_to_value(field_name: field.name, options: options)
            }
          end
        end.compact
      when 3
        fields.map do |field|
          values = Array(model.try(field.name)).map { |value| scrub(value.to_s) }
          next if values.empty?
          {
            'label' => {
              # Since we're using I18n to translate the field, we're setting the locale used in the translation.
              I18n.locale.to_s => [Hyrax::Renderers::AttributeRenderer.new(field.name, nil).label]
            },
            'value' => {
              "none" => values
            }
          }
        end.compact
      else
        raise IiifPrintError, "Version #{version} not implemented"
      end
    end
    # rubocop:enable MethodLength, CyclomaticComplexity, PerceivedComplexity, AbcSize

    private

    def scrub(value)
      Loofah.fragment(value).scrub!(:whitewash).to_s
    end

    def cast_to_value(field_name:, options:)
      if options&.[](:render_as) == :faceted
        Array(model.send(field_name)).map do |value|
          search_field = field_name.to_s + "_sim"
          path = Rails.application.routes.url_helpers.search_catalog_path(
            "f[#{search_field}][]": value, locale: I18n.locale
          )
          path += '&include_child_works=true' if model["is_child_bsi"] == true
          "<a href='#{path}'>#{value}</a>"
        end
      else
        make_link(model.send(field_name))
      end
    end

    def make_collection_link(collection_documents)
      collection_documents.map do |collection|
        "<a href='/collections/#{collection.id}'>#{collection.title.first}</a>"
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
  # rubocop:enable Metrics/ModuleLength, Metrics/ClassLength
end
