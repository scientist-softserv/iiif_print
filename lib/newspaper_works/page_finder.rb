# useful methods for retrieving and ordering NewspaperPage objects
module NewspaperWorks
  module PageFinder
    ##
    # find all pages for an issue, return in order
    # @param issue_id [String]
    # @return [Array] ordered NewspaperPage SolrDocuments for an issue
    def pages_for_issue(issue_id)
      solr_params = ["has_model_ssim:\"NewspaperPage\""]
      solr_params << "issue_id_ssi:\"#{issue_id}\""
      solr_resp = Blacklight.default_index.search(fq: solr_params.join(' AND '))
      all_pages = solr_resp.documents
      return [] if all_pages.blank?
      ordered_pages(all_pages)
    end

    ##
    # return an ordered array of NewspaperPage documents
    # @param documents [Array] NewspaperPage SolrDocuments for an issue
    # @return [Array] ordered NewspaperPage SolrDocuments for an issue
    def ordered_pages(documents)
      return documents if documents.length <= 1
      ordered_list = []
      next_page_id, final_page_id = nil
      documents.each do |doc|
        if doc['is_following_page_of_ssi'].blank?
          ordered_list.insert(0, doc)
          next_page_id = doc['is_preceding_page_of_ssi']
        elsif doc['is_preceding_page_of_ssi'].blank?
          ordered_list.insert(-1, doc)
          final_page_id = doc['id']
        end
      end
      while next_page_id != final_page_id
        next_page = documents.select { |doc| doc['id'] == next_page_id }.first
        ordered_list.insert(-2, next_page)
        next_page_id = next_page['is_preceding_page_of_ssi']
      end
      ordered_list
    end

    ##
    # return the index of the current page
    # @param page_id [String] id of the NewspaperPage
    # @return [Integer] the page's index
    def get_page_index(page_id)
      default_index = 0
      page_doc = SolrDocument.find(page_id)
      return default_index unless page_doc &&
          page_doc['issue_id_ssi'] && page_doc['is_following_page_of_ssi']
      all_pages = pages_for_issue(page_doc['issue_id_ssi'])
      return default_index if all_pages.blank?
      all_pages.index { |page| page['id'] == page_id }
    end
  end
end