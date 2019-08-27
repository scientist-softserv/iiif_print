# Generated via
#  `rails generate hyrax:work NewspaperIssue`
module Hyrax
  class NewspaperIssuePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    include NewspaperWorks::TitleInfoPresenter
    include NewspaperWorks::IiifManifestPresenterBehavior

    delegate :volume, :edition_number, :edition_name,
             :issue_number, :extent, to: :solr_document

    # @return [Boolean] render the UniversalViewer
    def iiif_viewer?
      Hyrax.config.iiif_image_server? && members_include_viewable_page?
    end

    def publication_date
      solr_document["publication_date_dtsi"]
    end

    def persistent_url
      return nil unless publication_unique_id && issue_date_for_url
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
            presenter.iiif_viewer? &&
            current_ability.can?(:read, presenter.id)
        end
      end

      def publication_unique_id
        solr_document['publication_unique_id_ssi'] || nil
      end

      def issue_date_for_url
        return nil unless publication_date
        publication_date.match(/\A[\d]{4}-[\d]{2}-[\d]{2}/).to_s
      end

      def edition_for_url
        "ed-#{edition_number ? edition_number.first : '1'}"
      end

      def iiif_metadata_fields
        [:title, :alternative_title, :place_of_publication_label, :issn, :lccn,
         :oclcnum, :held_by, :volume, :edition_name, :edition_number,
         :issue_number, :extent, :publication_date, :resource_type, :creator,
         :contributor, :description, :license, :rights_statement, :publisher,
         :language, :identifier]
      end
  end
end
