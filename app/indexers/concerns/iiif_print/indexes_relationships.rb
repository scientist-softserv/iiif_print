# indexes parent relationships e.g. issue->title, page->issue, etc
module IiifPrint
  module IndexesRelationships
    # index relationships
    #
    # @param object [Newspaper*] an instance of a IiifPrint model
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_relationships(object, solr_doc)
      index_publication(object, solr_doc) unless object.is_a?(NewspaperTitle)
      case object
      when NewspaperPage
        index_issue(object, solr_doc)
        index_container(object, solr_doc)
        index_articles(object, solr_doc)
        index_siblings(object, solr_doc)
      when NewspaperArticle
        index_issue(object, solr_doc)
        index_pages(object, solr_doc)
      end
    end

    # index the publication info
    #
    # @param object [Newspaper*] an instance of a IiifPrint model
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_publication(object, solr_doc)
      newspaper_title = object.publication
      return unless newspaper_title.is_a?(NewspaperTitle)
      solr_doc['publication_id_ssi'] = newspaper_title.id
      solr_doc['publication_title_ssi'] = newspaper_title.title.first
      publication_unique_id = newspaper_title.send(IiifPrint.config.publication_unique_id_property)
      solr_doc['publication_unique_id_ssi'] = publication_unique_id
      index_parent_facets(newspaper_title, solr_doc)
    end

    # index the issue info
    #
    # @param object [NewspaperPage||NewspaperArticle]
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_issue(object, solr_doc)
      newspaper_issue = object.issue
      return unless newspaper_issue.is_a?(NewspaperIssue)
      solr_doc['issue_id_ssi'] = newspaper_issue.id
      solr_doc['issue_title_ssi'] = newspaper_issue.title.first
      solr_doc['publication_date_dtsi'] ||= newspaper_issue.publication_date.to_datetime if newspaper_issue.publication_date.present?
      solr_doc['issue_volume_ssi'] = newspaper_issue.volume
      solr_doc['issue_edition_number_ssi'] = newspaper_issue.edition_number || '1'
      solr_doc['issue_number_ssi'] = newspaper_issue.issue_number
      index_parent_facets(newspaper_issue, solr_doc)
    end

    # index the pages info
    #
    # @param article [NewspaperArticle]
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_pages(article, solr_doc)
      newspaper_pages = article.pages
      return if newspaper_pages.blank? || !newspaper_pages.first.is_a?(NewspaperPage)
      solr_doc['page_ids_ssim'] = []
      solr_doc['page_titles_ssim'] = []
      newspaper_pages.each do |n_page|
        solr_doc['page_ids_ssim'] << n_page.id
        solr_doc['page_titles_ssim'] << n_page.title.first
      end
    end

    # index previous/next siblings info
    #
    # @param page [NewspaperPage]
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_siblings(page, solr_doc)
      newspaper_issue = page.issue
      return unless newspaper_issue.is_a?(NewspaperIssue)
      page_ids = newspaper_issue.ordered_page_ids
      this_page_index = page_ids.index(page.id)
      return unless this_page_index
      solr_doc['is_following_page_of_ssi'] = page_ids[this_page_index - 1].presence unless this_page_index.zero?
      solr_doc['is_preceding_page_of_ssi'] = page_ids[this_page_index + 1].presence
      solr_doc['first_page_bsi'] = true if this_page_index.zero?
    end

    # index the articles info
    #
    # @param page [NewspaperPage]
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_articles(page, solr_doc)
      newspaper_articles = page.articles
      return if newspaper_articles.blank? || !newspaper_articles.first.is_a?(NewspaperArticle)
      solr_doc['article_ids_ssim'] = []
      solr_doc['article_titles_ssim'] = []
      newspaper_articles.each do |n_article|
        solr_doc['article_ids_ssim'] << n_article.id
        solr_doc['article_titles_ssim'] << n_article.title.first
      end
    end

    # index common facet properties
    # TODO: this could probably be DRY'd out a bit,
    # overlaps with IndexesPlaceOfPublication#index_pop
    #
    # @param parent [NewspaperTitle||NewspaperIssue]
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_parent_facets(parent, solr_doc)
      parent_doc = parent.to_solr
      fields = %w[language_sim place_of_publication_label_sim
                  place_of_publication_city_sim place_of_publication_county_sim
                  place_of_publication_state_sim place_of_publication_country_sim
                  place_of_publication_coords_sim place_of_publication_label_tesim]
      fields.each do |field|
        solr_doc[field] ||= parent_doc[field]
      end
    end
  end
end
