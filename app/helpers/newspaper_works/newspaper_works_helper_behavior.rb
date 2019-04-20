module NewspaperWorks
  module NewspaperWorksHelperBehavior
    ##
    # create link anchor to be read by UniversalViewer
    # in order to show keyword search
    # @param query [String]
    # @return [String] or [nil] anchor
    def iiif_search_anchor(query)
      return nil if query.blank?
      "?h=#{query}"
    end

    ##
    # based on Blacklight::CatalogHelperBehavior#render_thumbnail_tag
    # setup the thumbnail link for a NewspaperPage or Article
    #
    # @param document [SolrDocument]
    # @param query [String]
    # @return [String]
    def render_newspaper_thumbnail_tag(document, query)
      thumbnail = newspaper_thumbnail_tag(document)
      return unless thumbnail
      anchor = iiif_search_anchor(query)
      case document[blacklight_config.view_config(document_index_view_type).display_type_field].first
      when 'NewspaperPage'
        link_to(thumbnail, hyrax_newspaper_page_path(document.id, anchor: anchor))
      when 'NewspaperArticle'
        link_to(thumbnail, hyrax_newspaper_article_path(document.id, anchor: anchor))
      else
        link_to_document document, thumbnail
      end
    end

    ##
    # based on Blacklight::CatalogHelperBehavior#render_thumbnail_tag
    # return the thumbnail image_tag
    #
    # @param document [SolrDocument]
    # @return [String]
    def newspaper_thumbnail_tag(document)
      if blacklight_config.view_config(document_index_view_type).thumbnail_method
        send(blacklight_config.view_config(document_index_view_type).thumbnail_method,
             document)
      elsif blacklight_config.view_config(document_index_view_type).thumbnail_field
        url = thumbnail_url(document)
        image_tag url if url.present?
      end
    end
  end
end
