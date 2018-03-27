# Generated via
#  `rails generate hyrax:work NewspaperArticle`

module Hyrax
  class NewspaperArticlesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::NewspaperArticle

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::NewspaperArticlePresenter
  end
end
