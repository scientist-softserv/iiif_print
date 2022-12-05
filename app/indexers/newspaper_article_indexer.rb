# Generated via
#  `rails generate hyrax:work NewspaperArticle`
class NewspaperArticleIndexer < IiifPrint::NewspaperCoreIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      # index the labels for the genre URIs, as searchable and facetable
      article_genre_service = Hyrax::ArticleGenreService.new
      genre_labels = []
      object.genre.each do |value|
        genre_labels << article_genre_service.label(value) { value }
      end
      solr_doc['genre_tesim'] = genre_labels.presence
      solr_doc['genre_sim'] = genre_labels.presence
    end
  end
end
