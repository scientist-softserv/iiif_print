# Generated via
#  `rails generate hyrax:work NewspaperIssue`

module Hyrax
  class NewspaperIssuesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::NewspaperIssue

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::NewspaperIssuePresenter
  end
end
