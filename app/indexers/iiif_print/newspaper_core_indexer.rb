# Core indexer for newspaper work types
module NewspaperWorks
  class NewspaperCoreIndexer < Hyrax::WorkIndexer
    # This indexes the default metadata. You can remove it if you want to
    # provide your own metadata and indexing.
    include Hyrax::IndexesBasicMetadata
    include NewspaperWorks::IndexesPlaceOfPublication
    include NewspaperWorks::IndexesRelationships

    # Fetch remote labels for based_near. You can remove this if you don't want
    # this behavior
    # include Hyrax::IndexesLinkedMetadata

    def generate_solr_document
      super.tap do |solr_doc|
        index_pop(object, solr_doc)
        index_relationships(object, solr_doc)
      end
    end
  end
end
