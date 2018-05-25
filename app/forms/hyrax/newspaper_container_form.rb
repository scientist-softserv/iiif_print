# Generated via
#  `rails generate hyrax:work NewspaperContainer`
module Hyrax
  # Newspaper Container Form Class
  class NewspaperContainerForm < ::NewspaperWorks::NewspaperCoreFormData
    self.model_class = ::NewspaperContainer
    self.terms += [:alternative_title, :extent]
    self.terms -= [:creator, :contributor, :description, :subject]
  end
end
