# indexes the full text of a Newspaper object
module NewspaperWorks
  module IndexesFullText
    # index full text
    # load text from plain text derivative
    # then index as *both* stored and non-stored Solr text field
    # former needed for search hit highlighting, latter is Hyrax default
    #
    # @param work [Newspaper*] an instance of a NewspaperWorks model
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_full_text(work, solr_doc)
      text = NewspaperWorks::Data::WorkDerivatives.new(work).data('txt')
      solr_doc['all_text_timv'] = text
      solr_doc['all_text_tsimv'] = text
    end
  end
end
