# Generated via
#  `rails generate hyrax:work NewspaperIssue`
module Hyrax
  class NewspaperIssueForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperIssue
    self.terms += [
      :title,
      :resource_type,
      :genre,
      :language,
      :held_by,
      :issued,
      :alternative_title
    ]
    self.required_fields = [
      :title,
      :resource_type,
      :genre,
      :language,
      :held_by
    ]
  end
end
