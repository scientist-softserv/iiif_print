# indexes the full text of a Newspaper object
module NewspaperWorks
  module IndexesFullText
    # index full text
    # load text from plain text derivative
    # index as *both* stored (for highlighting) and non-stored (Hyrax default) text field
    #
    # @param work [Newspaper*] an instance of a NewspaperWorks model
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    # rubocop:disable Performance/StringReplacement
    def index_full_text(work, solr_doc)
      text = NewspaperWorks::Data::WorkDerivatives.new(work).data('txt')
      text = text.gsub(/\n/, ' ').squeeze(' ')
      solr_doc['all_text_timv'] = text
      solr_doc['all_text_tsimv'] = text
    end
    # rubocop:enable Performance/StringReplacement
  end
end
