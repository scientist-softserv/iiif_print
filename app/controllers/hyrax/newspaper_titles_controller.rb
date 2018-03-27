# Generated via
#  `rails generate hyrax:work NewspaperTitle`

module Hyrax
  class NewspaperTitlesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::NewspaperTitle

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::NewspaperTitlePresenter
  end
end
