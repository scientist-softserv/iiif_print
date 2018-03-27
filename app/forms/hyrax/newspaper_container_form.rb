# Generated via
#  `rails generate hyrax:work NewspaperContainer`
module Hyrax
  class NewspaperContainerForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperContainer
    self.required_fields = [:resource_type, :genre, :language, :held_by]
    self.terms += [:resource_type]
  end
end
