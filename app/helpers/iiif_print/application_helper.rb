module IiifPrint
  # Application Helper module
  module ApplicationHelper
    ##
    # This is in place to coerce the :q string to :query for passing the :q value to the query value
    # of a IIIF Print manifest.
    #
    # @param doc [SolrDocument]
    # @param request [ActionDispatch::Request]
    #
    # @return [String]
    def generate_work_url(doc, request)
      url = super
      return url if request.params[:q].blank?

      key = doc.any_highlighting? ? 'parent_query' : 'query'
      query = { key => request.params[:q] }.to_query
      if url.include?("?")
        url + "&#{query}"
      else
        url + "?#{query}"
      end
    end
  end
end
