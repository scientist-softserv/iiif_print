module IiifPrint::Solr::Document
  # @note Why decorate?  We want to avoid including this module via generator.  And the generator
  #       previously did two things: 1) include `IiifPrint::Solr::Document` in `SolrDocument`; 2)
  #       add the `attribute :is_child` field to the SolrDocument.  We can't rely on `included do`
  #       block to handle that.
  #
  # This method is responsible for configuring the SolrDocument for a Hyrax/Hyku application.  It
  # does three things:
  #
  # 1. Adds instance methods to the SolrDocument (see implementation below)
  # 2. Adds the `is_child` attribute to the SolrDocument
  # 3. Adds a class attribute (e.g. `iiif_print_solr_field_names`) to allow further customization.
  #
  # @note These `iiif_print_solr_field_names` came from the newspaper_works implementation and are
  #       carried forward without much consideration, except to say "Make it configurable!"
  #
  # @param base [Class<SolrDocument>]
  # @return [Class<SolrDocument>]
  def self.decorate(base)
    base.prepend(self)
    base.send(:attribute, :is_child, Hyrax::SolrDocument::Metadata::Solr::String, 'is_child_bsi')
    base.send(:attribute, :split_from_pdf_id, Hyrax::SolrDocument::Metadata::Solr::String, 'split_from_pdf_id_ssi')
    base.send(:attribute, :digest, Hyrax::SolrDocument::Metadata::Solr::String, 'digest_ssim')

    # @note These properties came from the newspaper_works gem.  They are configurable.
    base.class_attribute :iiif_print_solr_field_names, default: %w[alternative_title genre
                                                                   issn lccn oclcnum held_by text_direction
                                                                   page_number section author photographer
                                                                   volume issue_number geographic_coverage
                                                                   extent publication_date height width
                                                                   edition_number edition_name frequency preceded_by
                                                                   succeeded_by]
    base
  end

  def digest_sha1
    digest[/urn:sha1:([\w]+)/, 1]
  end

  def method_missing(method_name, *args, &block)
    super unless iiif_print_solr_field_names.include? method_name.to_s
    self[IiifPrint.solr_name(method_name.to_s)]
  end

  def respond_to_missing?(method_name, include_private = false)
    iiif_print_solr_field_names.include?(method_name.to_s) || super
  end

  # @see https://github.com/samvera/hyrax/commit/7108409c619cd2ba4ae8c836b9f3b429a7e9837b
  def file_set_ids
    # Yes, this looks a little odd.  But the truth is the prior key (e.g. `file_set_ids_ssim`) was
    # an alias of `member_ids_ssim`.
    self['member_ids_ssim']
  end

  def any_highlighting?
    response&.[]('highlighting')&.[](id)&.present?
  end

  def solr_document
    self
  end
end
