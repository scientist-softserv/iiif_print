# Generated via
#  `rails generate hyrax:work NewspaperPage`
module Hyrax
  class NewspaperPagePresenter < Hyrax::WorkShowPresenter
    include IiifPrint::ScannedMediaPresenter
    include IiifPrint::TitleInfoPresenter
    include IiifPrint::IssueInfoPresenter
    include IiifPrint::IiifManifestPresenterBehavior
    include IiifPrint::PersistentUrlPresenterBehavior
    include IiifPrint::PageFinder
    include IiifPrint::PlaceOfPublicationPresenterBehavior

    delegate :height, :width, to: :solr_document

    def persistent_url
      return nil unless publication_unique_id && issue_date_for_url
      IiifPrint::Engine.routes.url_helpers.newspaper_page_url(unique_id: publication_unique_id,
                                                                   date: issue_date_for_url,
                                                                   edition: edition_for_url,
                                                                   page: page_index_for_url,
                                                                   host: request.host)
    end

    def previous_page_id
      solr_document['is_following_page_of_ssi']
    end

    def next_page_id
      solr_document['is_preceding_page_of_ssi']
    end

    def container_id
      solr_document['container_id_ssi']
    end

    def container_title
      solr_document['container_title_ssi']
    end

    def article_ids
      solr_document['article_ids_ssim']
    end

    def article_titles
      solr_document['article_titles_ssim']
    end

    private

    def publication_unique_id
      solr_document['publication_unique_id_ssi'] || nil
    end

    def issue_date_for_url
      return nil unless publication_date
      publication_date.match(/\A[\d]{4}-[\d]{2}-[\d]{2}/).to_s
    end

    def edition_for_url
      "ed-#{solr_document['issue_edition_number_ssi'] || '1'}"
    end

    def page_index_for_url
      "seq-#{get_page_index(id, solr_document['issue_id_ssi']) + 1}"
    end

    def iiif_metadata_fields
      [:title, :text_direction, :page_number, :section, :resource_type,
       :license, :rights_statement, :identifier, :publication_date]
    end
  end
end
