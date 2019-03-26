module NewspaperWorks
  module PageOrder
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
  end
end