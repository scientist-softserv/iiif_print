# Generated via
#  `rails generate hyrax:work NewspaperPage`
module Hyrax
  class NewspaperPagePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::ScannedMediaPresenter
    include NewspaperWorks::IiifSearchPresenterBehavior
    include NewspaperWorks::PersistentUrlPresenterBehavior
    include NewspaperWorks::PageFinder

    delegate :height, :width, to: :solr_document

    def persistent_url
      NewspaperWorks::Engine.routes.url_helpers.newspaper_page_url(unique_id: publication_unique_id,
                                                                   date: issue_date_for_url,
                                                                   edition: edition_for_url,
                                                                   page: page_index_for_url,
                                                                   host: request.host)
    end

    private

      def publication_unique_id
        solr_document['publication_unique_id_ssi']
      end

      def issue_date_for_url
        return '0000-00-00' unless solr_document['issue_pubdate_dtsi']
        solr_document['issue_pubdate_dtsi'].match(/\A[0-9]{4}-[0-3]{2}-[0-9]{2}/).to_s
      end

      def edition_for_url
        "ed-#{solr_document['issue_edition_ssi'] || '1'}"
      end

      def page_index_for_url
        "seq-#{(get_page_index(id) + 1)}"
      end
  end
end
