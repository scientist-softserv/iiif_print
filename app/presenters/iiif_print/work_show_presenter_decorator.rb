# frozen_string_literal: true

module IiifPrint
  module WorkShowPresenterDecorator
    delegate :file_set_ids, to: :solr_document

    # OVERRIDE Hyrax 2.9.6 to remove check for representative_presenter.image?
    # @return [Boolean] render a IIIF viewer
    def iiif_viewer?
      Hyrax.config.iiif_image_server? &&
      representative_id.present? &&
      representative_presenter.present? &&
      members_include_viewable_image?
    end

    alias universal_viewer? iiif_viewer?

    private

    # overriding Hyrax to include file sets for both work and child works (file set ids include both)
    # process each id, short-circuiting the loop once one true value is found. This spees up the test
    # by not loading more member_presenters than needed.
    def members_include_viewable_image?
      all_member_ids = (solr_document.try(:file_set_ids) || solr_document.try(:[], 'file_set_ids_ssim'))
      all_member_ids.each do |id|
        return true if file_type_and_permissions_valid?(member_presenters_for([id]).first)
      end
      false
    end

    # This method allows for overriding to add additional file types to mix in with IiifAv
    # TODO: add configuration setting for file types to loop through so an override is unneeded.
    def file_type_and_permissions_valid?(presenter)
      current_ability.can?(:read, presenter.id) && 
      (presenter.try(:image?) || presenter.try(:solr_document).try(:image?))
    end
  end
end
