module IiifPrint
  module Metadata
    # rubocop:disable Metrics/MethodLength
    def self.manifest_for(model:, version:, fields:)
      case version
      when 2
        fields.map do |field|
          {
            'label' => field.label,
            'value' => Array(model.public_send(field.name)).map { |value| scrub(value.to_s) }
          }
        end
      when 3
        fields.map do |field|
          {
            'label' => {
              # Since we're using I18n to translate the field, we're setting the locale used in the translation.
              I18n.locale.to_s => [field.label]
            },
            'value' => {
              "none" => Array(model.public_send(field.name)).map { |value| scrub(value.to_s) }
            }
          }
        end
      else
        raise IiifPrintError, "Version #{version} not implemented"
      end
    end
    # rubocop:enable Metrics/MethodLength

    # Hash is an arbitrary attribute key/value pairs
    # Struct is a defined set of attribute "keys".  When we favor defined values,
    # then we are naming the concept and defining the range of potential values.
    Field = Struct.new(:name, :label, keyword_init: true)

    def self.default_fields_for(model)
      model.metadata_fields.map do |field|
        Field.new(name: field, label: I18n.t("simple_form.labels.defaults.#{field}", fallback: field.to_s.titleize))
      end
    end

    def self.default_fields_for_allinson_flex(model)
      if defined?(AllinsonFlex)
        # SQL here
      else
        default_fields_for(model)
      end
    end

    # @api private
    def self.scrub(value)
      Loofah.fragment(value).scrub!(:whitewash).to_s
    end
  end
end
