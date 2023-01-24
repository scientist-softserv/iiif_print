# frozen_string_literal: true

module IiifPrint
  module WorkShowPresenterDecorator
    # OVERRIDE: Hyrax 2.9.6
    def total_pages(members = nil)
      # if we're hiding the derivatives, we won't have as many pages to show
      pages = members.presence || total_items

      (pages.to_f / rows_from_params.to_f).ceil
    end

    delegate :file_set_ids, to: :solr_document

    # OVERRIDE Hyrax 2.9.6 to remove check for representative_presenter.image? and allow
    # a fallback to check for images on the child works
    # @return [Boolean] render a IIIF viewer
    def iiif_viewer?
      parent_work_has_files? || child_work_has_files?
    end

    private

    def parent_work_has_files?
      Hyrax.config.iiif_image_server? &&
        representative_id.present? &&
        representative_presenter.present? &&
        members_include_viewable_image?
    end

    def child_work_has_files?
      file_set_ids.present?
    end
  end
end
