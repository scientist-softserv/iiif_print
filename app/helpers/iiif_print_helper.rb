module IiifPrintHelper
  ##
  # create link anchor to be read by UniversalViewer
  # in order to show keyword search
  # @param query_params_hash [Hash] current_search_session.query_params
  # @return [String] or [nil] anchor
  def iiif_search_anchor(query_params_hash)
    query = search_query(query_params_hash)
    return nil if query.blank?
    "?h=#{query}"
  end

  ##
  # get the query, which may be in a different object,
  #   depending if regular search or newspapers_search was run
  # @param query_params_hash [Hash] current_search_session.query_params
  # @return [String] or [nil] query
  def search_query(query_params_hash)
    query_params_hash[:q] || query_params_hash[:all_fields]
  end

  ##
  # return the matching highlighted terms from Solr highlight field
  #
  # @param document [SolrDocument]
  # @param hl_fl [String] the name of the Solr field with highlights
  # @param hl_tag [String] the HTML element name used for marking highlights
  #   configured in Solr as hl.tag.pre value
  # @return [String]
  def highlight_matches(document, hl_fl, hl_tag)
    hl_matches = []
    # regex: find all chars between hl_tag, but NOT other <element>
    regex = /<#{hl_tag}>[^<>]+<\/#{hl_tag}>/
    hls = document.highlight_field(hl_fl)
    return nil if hls.blank?
    hls.each do |hl|
      matches = hl.scan(regex)
      matches.each do |match|
        hl_matches << match.gsub(/<[\/]*#{hl_tag}>/, '').downcase
      end
    end
    hl_matches.uniq.sort.join(' ')
  end
end
