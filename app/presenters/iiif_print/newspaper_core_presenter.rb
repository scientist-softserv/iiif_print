# module comment...
module NewspaperWorks
  # core presenter for newspaper models
  module NewspaperCorePresenter
    include NewspaperWorks::PersistentUrlPresenterBehavior
    include NewspaperWorks::PlaceOfPublicationPresenterBehavior
    delegate :alternative_title, :issn, :lccn, :oclcnum, :held_by, to: :solr_document
  end
end
