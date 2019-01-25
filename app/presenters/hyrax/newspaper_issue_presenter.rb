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
  end
end
