class NewspaperPageIndexer < NewspaperWorks::NewspaperCoreIndexer
  include NewspaperWorks::IndexesFullText

  def generate_solr_document
    super.tap do |solr_doc|
      index_full_text(object, solr_doc)
    end
  end
end
