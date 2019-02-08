# based on Hyrax::RightsStatementService
module Hyrax
  # Provide select options for the NewspaperArticle genre (edm:hasType) field
  class ArticleGenreService < QaSelectService
    def initialize(_authority_name = nil)
      super('newspaper_article_genres')
    end
  end
end
