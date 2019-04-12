# mixin to provide persistent URL methods
module NewspaperWorks
  module PersistentUrlPresenterBehavior
    # Default for NewspaperContainer and NewspaperArticle,
    # since we don't support ChronAm-style URLs for those object types.
    # Override in individual presenters as needed.
    def persistent_url
      nil
    end

    def persistent_url_attribute
      return nil unless persistent_url
      renderer_for(:persistent_url, {}).new(:persistent_url, persistent_url).render_dl_row
    end
  end
end