module IiifPrint
  module WorksControllerBehaviorDecorator
    def manifest
      headers['Access-Control-Allow-Origin'] = '*'
      base_url = request.base_url

      json = iiif_manifest_builder.manifest_for(presenter: iiif_manifest_presenter,
                                                current_ability: current_ability,
                                                base_url: base_url)

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end
  end
end
