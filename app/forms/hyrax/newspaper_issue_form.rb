# Generated via
#  `rails generate hyrax:work NewspaperIssue`
module Hyrax
  # Newspaper Issue Form Class
  class NewspaperIssueForm < ::IiifPrint::NewspaperCoreFormData
    self.model_class = ::NewspaperIssue
    self.terms += [:alternative_title, :volume, :edition_number, :edition_name,
                   :issue_number, :extent, :publication_date]
    self.terms -= [:creator, :contributor, :description, :subject]
  end
end
