module IiifPrint
  module WorksControllerBehaviorDecorator
    # Extending the presenter to the base url which includes the protocol.
    # We need the base url to render the facet links.
    def iiif_manifest_presenter
      super.tap { |i| i.base_url = request.base_url }
    end
  end
end
Hyrax::WorksControllerBehavior.prepend(IiifPrint::WorksControllerBehaviorDecorator)
# Hyku::WorksControllerBehavior was introduced in Hyku v6.0.0+.  Yes we don't depend on Hyku,
# but this allows us to do minimal Hyku antics with IiifPrint.
'Hyku::WorksControllerBehavior'.safe_constantize&.prepend(IiifPrint::WorksControllerBehaviorDecorator)
