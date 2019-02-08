# module comment...
module NewspaperWorks
  # core presenter for newspaper models
  module NewspaperCorePresenter
    delegate :alternative_title, :issn, :lccn, :oclcnum, :held_by, to: :solr_document

    def place_of_publication_label
      solr_document["place_of_publication_label_tesim"]
    end
  end
end
