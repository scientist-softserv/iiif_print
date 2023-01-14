module IiifPrint
  module WorksControllerBehaviorDecorator
    def manifest
      headers['Access-Control-Allow-Origin'] = '*'

      json = iiif_manifest_builder.manifest_for(presenter: iiif_manifest_presenter, current_ability: current_ability)

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end
  end
end
