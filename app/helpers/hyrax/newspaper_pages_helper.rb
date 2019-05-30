module Hyrax
  module NewspaperPagesHelper
    include NewspaperWorks::BreadcrumbHelper

    # create link to the previous NewspaperPage
    #
    # @param presenter [NewspaperPagePresenter] the presenter for the current NewspaperPage object
    # @param options [Hash] a hash of link options
    def previous_page_link(presenter, options = {})
      link_to("<< #{t('hyrax.newspaper_page.previous_page')}",
              main_app.hyrax_newspaper_page_path(presenter.previous_page_id),
              options)
    end

    # create link to the next NewspaperPage
    #
    # @param presenter [NewspaperPagePresenter] the presenter for the current NewspaperPage object
    # @param options [Hash] a hash of link options
    def next_page_link(presenter, options = {})
      link_to("#{t('hyrax.newspaper_page.next_page')} >>",
              main_app.hyrax_newspaper_page_path(presenter.next_page_id),
              options)
    end
  end
end
