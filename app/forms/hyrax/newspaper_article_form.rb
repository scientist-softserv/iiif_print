# Generated via
#  `rails generate hyrax:work NewspaperArticle`
module Hyrax
  class NewspaperArticleForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperArticle
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
