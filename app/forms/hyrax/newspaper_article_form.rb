# Generated via
#  `rails generate hyrax:work NewspaperArticle`
module Hyrax
  class NewspaperArticleForm < ::NewspaperWorks::NewspaperCoreFormData
    self.model_class = ::NewspaperArticle
    self.terms += [:alternative_title, :author, :photographer, :volume,
                   :edition, :issue, :geographic_coverage, :extent,
                   :page_number, :section]
  end
end
