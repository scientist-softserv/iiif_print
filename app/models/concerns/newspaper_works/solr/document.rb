module NewspaperWorks::Solr::Document
  SOLR_NAMES = ["alternative_title", "genre", "place_of_publication",
                "issn", "lccn", "oclcnum", "held_by", "text_direction",
                "page_number", "section", "author", "photographer",
                "volume", "issue_number", "geographic_coverage",
                "extent", "publication_date", "height", "width",
                "edition", "frequency", "preceded_by", "succeeded_by",
                "publication_date_start", "publication_date_end"].freeze

  def method_missing(m, *args, &block)
    super unless SOLR_NAMES.include? m.to_s
    self[Solrizer.solr_name(m.to_s)]
  end

  def respond_to_missing?(method_name, include_private = false)
    SOLR_NAMES.include?(method_name.to_s) || super
  end
end
