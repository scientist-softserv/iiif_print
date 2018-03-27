# Generated via
#  `rails generate hyrax:work NewspaperContainer`

module Hyrax
  class NewspaperContainersController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::NewspaperContainer

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::NewspaperContainerPresenter
  end
end
