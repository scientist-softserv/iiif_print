module IiifPrint
  module BreadcrumbHelper
    # create an array of links representing the ancestors of the current object
    #
    # @param presenter [Newspaper*Presenter] the presenter for the current Newspaper object
    # @param link_class [String] the class for the breadcrumb links
    def newspaper_breadcrumbs(presenter, link_class = nil)
      breadcrumbs = []
      ancestors = { title: :publication_id, issue: :issue_id, page: :page_ids }
      ancestors.each do |k, v|
        breadcrumbs << create_breadcrumb_link(k, presenter, link_class) if presenter.respond_to?(v)
      end
      breadcrumbs << breadcrumb_object_title(presenter.title.first)
      breadcrumbs.flatten
    end

    # create an array of links representing ancestors of the current object
    #
    # @param object_type [Symbol] the type of newspaper object, as a symbol (e.g. :issue)
    # @param presenter [Newspaper*Presenter] the presenter for the current Newspaper object
    # @param link_class [String] the class for the breadcrumb links
    def create_breadcrumb_link(object_type, presenter, link_class = nil)
      links = []
      case object_type
      when :title
        links << breadcrumb_object_link(object_type, presenter.publication_id,
                                        presenter.publication_title, link_class)
      when :issue
        links << breadcrumb_object_link(object_type, presenter.issue_id,
                                        breadcrumb_object_title(presenter.issue_title), link_class)
      when :page
        unless presenter.page_ids.blank? || presenter.page_titles.blank?
          presenter.page_ids.each_with_index do |id, index|
            links << breadcrumb_object_link(object_type, id, breadcrumb_object_title(presenter.page_titles[index]),
                                            link_class)
          end
        end
      end
      links
    end

    # create a link for an ancestor of the current object
    #
    # @param object_type [Symbol] the type of newspaper object, as a symbol (e.g. :issue)
    # @param id [String] the id of the ancestor Newspaper object
    # @param title [String] the title of the ancestor Newspaper object
    # @param link_class [String] the class for the breadcrumb links
    def breadcrumb_object_link(object_type, id, title, link_class = nil)
      return [] unless id && title
      link_path = "hyrax_newspaper_#{object_type}_path"
      link_to(title,
              main_app.send(link_path, id),
              class: link_class)
    end

    # Format link titles for ancestor link. Should return either the portion of
    # the title that describes the page number or a formatted date. If neither
    # is found, will return back the original title variable
    #
    # @param title [String] the title of the ancestor Newspaper object
    def breadcrumb_object_title(title)
      return nil unless title.is_a? String
      page_slice_start_index = title.downcase =~ /page/
      return title[page_slice_start_index..-1] if page_slice_start_index
      begin
        return title.to_date.strftime("%B %e, %Y")
      rescue ArgumentError
        return title
      end
    end

    # create link to the previous NewspaperPage
    #
    # @param presenter [NewspaperPagePresenter] presenter for current NewspaperPage object
    # @param options [Hash] hash of link options
    def previous_page_link(presenter, options = {})
      link_to("<< #{t('hyrax.newspaper_page.previous_page')}",
              main_app.hyrax_newspaper_page_path(presenter.previous_page_id),
              options)
    end

    # create link to the next NewspaperPage
    #
    # @param presenter [NewspaperPagePresenter] presenter for current NewspaperPage object
    # @param options [Hash] hash of link options
    def next_page_link(presenter, options = {})
      link_to("#{t('hyrax.newspaper_page.next_page')} >>",
              main_app.hyrax_newspaper_page_path(presenter.next_page_id),
              options)
    end
  end
end
