# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  # Newspaper Title Form Class
  class NewspaperTitleForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperTitle
    self.terms += [:title, :resource_type, :genre, :language, :held_by, :issued,
                   :place_of_publication, :alternative_title]
    self.required_fields = [:title, :resource_type, :genre, :language, :held_by]
  end
end
