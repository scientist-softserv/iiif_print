# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  # Newspaper Title Form Class
  class NewspaperTitleForm < ::NewspaperWorks::NewspaperCoreFormData
    self.model_class = ::NewspaperTitle
    self.terms += [:alternative_title, :edition, :frequency, :preceded_by,
                   :succeeded_by]
    self.terms -= [:creator, :contributor, :description, :source, :subject]
  end
end
