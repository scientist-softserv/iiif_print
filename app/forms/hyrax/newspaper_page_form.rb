# Generated via
#  `rails generate hyrax:work NewspaperPage`
module Hyrax
  # Newspaper Page Form Class
  class NewspaperPageForm < Hyrax::Forms::WorkForm
    self.model_class = ::NewspaperPage
    self.terms += [:height, :width, :resource_type, :text_direction,
                   :page_number, :section]
    self.terms -= [:creator, :keyword, :rights_statement, :contributor,
                   :description, :license, :subject, :date_created, :subject,
                   :language, :based_near, :related_url, :source,
                   :resource_type, :publisher]
    self.required_fields -= [:creator, :keyword, :rights_statement]
  end
end
