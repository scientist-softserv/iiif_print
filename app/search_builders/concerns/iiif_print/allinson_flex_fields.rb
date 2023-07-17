# frozen_string_literal: true

module IiifPrint
  module AllinsonFlexFields
    def include_allinson_flex_fields(solr_parameters)
      return unless defined?(AllinsonFlex)

      solr_parameters[:qf] += IiifPrint.allinson_flex_fields
                                       .each_with_object([]) do |field, arr|
        arr << (field.name + '_tesim') if field.is_a?(AllinsonFlex::ProfileProperty)
      end
                                       .join(' ')
    end
  end
end
