class NewspaperPageIndexer < NewspaperWorks::NewspaperCoreIndexer
  def index_full_text(solr_doc, work)
    # Get text from plain text derivative
    text = NewspaperWorks::Data::WorkDerivativeLoader.new(work).data('txt')
    # index as single-value text in solr:
    solr_doc['all_text_timv'] = text
  end

  def generate_solr_document
    super.tap do |solr_doc|
      index_full_text(solr_doc, object)
    end
  end
end
