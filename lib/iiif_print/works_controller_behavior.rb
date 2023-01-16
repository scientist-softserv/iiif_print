module IiifPrint
  module WorksControllerBehaviorDecorator
    # Extending the presenter to the base url which includes the protocol.
    # We need the base url to render the facet links.
    def iiif_manifest_presenter
      super.tap { |i| i.base_url = request.base_url }
    end
  end
end
