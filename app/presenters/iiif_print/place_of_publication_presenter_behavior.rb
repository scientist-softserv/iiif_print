# mixin to provide methods to render place_of_publication
module IiifPrint
  module PlaceOfPublicationPresenterBehavior
    def place_of_publication_label
      solr_document["place_of_publication_label_tesim"]
    end
  end
end
