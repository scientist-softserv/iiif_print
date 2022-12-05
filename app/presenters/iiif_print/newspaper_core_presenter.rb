# module comment...
module IiifPrint
  # core presenter for newspaper models
  module NewspaperCorePresenter
    include IiifPrint::PersistentUrlPresenterBehavior
    include IiifPrint::PlaceOfPublicationPresenterBehavior
    delegate :alternative_title, :issn, :lccn, :oclcnum, :held_by, to: :solr_document
  end
end
