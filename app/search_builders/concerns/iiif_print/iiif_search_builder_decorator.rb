# frozen_string_literal: true

# OVERRIDE BlacklightIiifSearch v1.0.0 to include AllinsonFlex fields in the search

module IiifPrint
  module IiifSearchBuilderDecorator
    # NOTE: ::IiifSearchBuilder.default_processor_chain += [:include_allinson_flex_fields]
    # is on the engine.rb file so this decorator is loaded before the `default_processor_chain` is set.
    include IiifPrint::AllinsonFlexFields
  end
end
