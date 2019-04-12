# Generated via
#  `rails generate hyrax:work NewspaperIssue`
module Hyrax
  class NewspaperIssuePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    include NewspaperWorks::IiifSearchPresenterBehavior
    delegate :volume, :edition, :issue_number, :extent, to: :solr_document

    # @return [Boolean] render the UniversalViewer
    def universal_viewer?
      Hyrax.config.iiif_image_server? && members_include_viewable_page?
    end

    def publication_date
      solr_document["publication_date_dtsim"]
    end

    def persistent_url
      NewspaperWorks::Engine.routes.url_helpers.newspaper_issue_edition_url(unique_id: publication_unique_id,
                                                                            date: issue_date_for_url,
                                                                            edition: edition_for_url,
                                                                            host: request.host)
    end

    private

      # modeled on Hyrax::WorkShowPresenter#members_include_viewable_image?
      # @return [Boolean] whether the member works will show in the IIIF viewer
      def members_include_viewable_page?
        work_presenters.any? do |presenter|
          presenter.model_name == 'NewspaperPage' &&
            presenter.universal_viewer? &&
            current_ability.can?(:read, presenter.id)
        end
      end

      def publication_unique_id
        solr_document['publication_unique_id_ssi']
      end

      def issue_date_for_url
        return '0000-00-00' unless publication_date
        publication_date.first.match(/\A[0-9]{4}-[0-3]{2}-[0-9]{2}/).to_s
      end

      def edition_for_url
        "ed-#{edition.first || '1'}"
      end
  end
end
