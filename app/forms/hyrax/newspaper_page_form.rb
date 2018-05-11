# Generated via
#  `rails generate hyrax:work NewspaperPage`
module Hyrax
  # Newspaper Page Form Class
  class NewspaperPageForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperPage
    self.required_fields = [:height, :width]
    self.terms += [:resource_type]
  end
end
