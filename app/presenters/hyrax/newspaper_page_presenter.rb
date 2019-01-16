# Generated via
#  `rails generate hyrax:work NewspaperPage`
module Hyrax
  class NewspaperPagePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::IiifSearchPresenterBehavior
  end
end
