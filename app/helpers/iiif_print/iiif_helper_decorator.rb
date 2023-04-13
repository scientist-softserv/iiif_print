# frozen_string_literal: true

# OVERRIDE Hyrax v2.9.6 add #uv_search_param

module IiifPrint
  module IiifHelperDecorator
    def iiif_viewer_display(work_presenter, locals = {})
      render iiif_viewer_display_partial(work_presenter),
             locals.merge(presenter: work_presenter)
    end

    def iiif_viewer_display_partial(work_presenter)
      'hyrax/base/iiif_viewers/' + work_presenter.iiif_viewer.to_s
    end

    def universal_viewer_base_url
      "#{request&.base_url}/uv/uv.html"
    end

    def universal_viewer_config_url
      "#{request&.base_url}/uv/uv-config.json"
    end

    # Extract query param from search
    def uv_search_param
      search_params = current_search_session.try(:query_params) || {}
      q = search_params['q'].presence || ''

      "&q=#{url_encode(q)}" if q.present?
    end
  end
end
