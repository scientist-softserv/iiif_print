# Core indexer for newspaper work types
module NewspaperWorks
  class NewspaperCoreIndexer < Hyrax::WorkIndexer
    # This indexes the default metadata. You can remove it if you want to
    # provide your own metadata and indexing.
    include Hyrax::IndexesBasicMetadata
    include NewspaperWorks::IndexesPlaceOfPublication

    # Fetch remote labels for based_near. You can remove this if you don't want
    # this behavior
    # include Hyrax::IndexesLinkedMetadata

    def generate_solr_document
      super.tap do |solr_doc|
        if defined? object.place_of_publication
          index_pop(object.place_of_publication, solr_doc) if object.place_of_publication.present?
        end
      end
    end
  end
end
