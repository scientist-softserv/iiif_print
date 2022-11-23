# Generated via
#  `rails generate hyrax:work NewspaperContainer`
module Hyrax
  class NewspaperContainerPresenter < Hyrax::WorkShowPresenter
    include IiifPrint::NewspaperCorePresenter
    include IiifPrint::TitleInfoPresenter

    delegate :extent, :publication_date_start, :publication_date_end,
             to: :solr_document
  end
end
