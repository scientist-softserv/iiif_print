require "iiif_print/engine"
require "iiif_print/errors"
require "iiif_print/jp2_image_metadata"
require "iiif_print/image_tool"
require "iiif_print/text_extraction"
require "iiif_print/data"
require "iiif_print/configuration"
require "iiif_print/base_derivative_service"
require "iiif_print/jp2_derivative_service"
require "iiif_print/pdf_derivative_service"
require "iiif_print/text_extraction_derivative_service"
require "iiif_print/text_formats_from_alto_service"
require "iiif_print/tiff_derivative_service"
require "iiif_print/lineage_service"
require "iiif_print/metadata"
require "iiif_print/works_controller_behavior"
require "iiif_print/jobs/application_job"
require "iiif_print/blacklight_iiif_search/annotation_decorator"
require "iiif_print/jobs/child_works_from_pdf_job"
require "iiif_print/jobs/create_relationships_job"
require "iiif_print/split_pdfs/base_splitter"
require "iiif_print/split_pdfs/child_work_creation_from_pdf_service"

module IiifPrint
  extend ActiveSupport::Autoload
  autoload :Configuration
  autoload :CatalogSearchBuilder

  ##
  # @api public
  #
  # Exposes the IiifPrint configuration.
  #
  # @yieldparam [IiifPrint::Configuration] config if a block is passed
  # @return [IiifPrint::Configuration]
  # @see IiifPrint::Configuration for configuration options
  def self.config(&block)
    @config ||= IiifPrint::Configuration.new
    yield @config if block
    @config
  end

  DEFAULT_MODEL_CONFIGURATION = {
    # Split a PDF into individual page images and create a new child work for each image.
    pdf_splitter_job: IiifPrint::Jobs::ChildWorksFromPdfJob,
    pdf_splitter_service: IiifPrint::SplitPdfs::PagesToJpgsSplitter,
    derivative_service_plugins: [
      IiifPrint::TextExtractionDerivativeService
    ]
  }.freeze

  # This is the record level configuration for PDF split handling.
  ModelConfig = Struct.new(:pdf_split_child_model, *DEFAULT_MODEL_CONFIGURATION.keys, keyword_init: true)
  private_constant :ModelConfig

  ##
  # @api public
  # This method is responsible for configuring a model for additional derivative generation.
  #
  # @example
  #   class Book < ActiveFedora::Base
  #     include IiifPrint.model_configuration(
  #       pdf_split_child_model: Page,
  #       derivative_service_plugins: [
  #         IiifPrint::JP2DerivativeService,
  #         IiifPrint::PDFDerivativeService,
  #         IiifPrint::TextExtractionDerivativeService,
  #         IiifPrint::TIFFDerivativeService
  #       ]
  #     )
  #   end
  #
  # @param kwargs [Hash<Symbol,Object>] the configuration values that overrides the
  #        DEFAULT_MODEL_CONFIGURATION.
  # @option kwargs [Array<Class>] derivative_service_plugins the various derivatives to run on the
  #        "original" files associated with this work.  Options include:
  #        {IiifPrint::JP2DerivativeService}, {IiifPrint::PDFDerivativeService},
  #        {IiifPrint::TextExtractionDerivativeService}, {IiifPrint::TIFFDerivativeService}
  # @option kwargs [Class] pdf_splitter_job responsible for handling the splitting of the original file
  # @option kwargs [Class] pdf_split_child_model when we split the file into pages, what's the child model
  #         we want for those pages?  Often times this is likely the same model as the parent.
  # @option kwargs [Class] pdf_splitter_service the specific service that splits the PDF.  Options are:
  #         {IiifPrint::SplitPdfs::PagesToJpgsSplitter},
  #         {IiifPrint::SplitPdfs::PagesToTiffsSplitter},
  #         {IiifPrint::SplitPdfs::PagesToPngsSplitter}
  #
  # @return [Module]
  #
  # @see IiifPrint::DEFAULT_MODEL_CONFIGURATION
  # @todo Because not every job will split PDFs and write to a child model. May want to introduce
  #       an alternative splitting method to create new filesets on the existing work instead of new child works.
  def self.model_configuration(**kwargs)
    Module.new do
      def iiif_print_config?
        true
      end

      # We don't know what you may want in your configuration, but from this gems implementation,
      # we're going to provide the defaults to ensure that it works.
      DEFAULT_MODEL_CONFIGURATION.each_pair do |key, default_value|
        kwargs[key] ||= default_value
      end

      define_method(:iiif_print_config) do
        @iiif_print_config ||= ModelConfig.new(**kwargs)
      end
    end
  end

  # @api public
  #
  # Map the given work's metadata to the given IIIF version spec's metadata structure.  This
  # is intended to be a drop-in replacement for `Hyrax::IiifManifestPresenter#manifest_metadata`.
  #
  # @param work [Object]
  # @param version [Integer]
  # @param fields [Array<IiifPrint::Metadata::Field>, Array<#name, #label>]
  # @return [Array<Hash>]
  #
  # @see specs for expected output
  #
  # @see Hyrax::IiifManifestPresenter#manifest_metadata
  def self.manifest_metadata_for(work:,
                                 version: config.default_iiif_manifest_version,
                                 fields: defined?(AllinsonFlex) ? allinson_flex_fields_for(work) : default_fields_for(work),
                                 current_ability:,
                                 base_url:)
    Metadata.build_metadata_for(work: work,
                                version: version,
                                fields: fields,
                                current_ability: current_ability,
                                base_url: base_url)
  end

  # Hash is an arbitrary attribute key/value pairs
  # Struct is a defined set of attribute "keys".  When we favor defined values,
  # then we are naming the concept and defining the range of potential values.
  Field = Struct.new(:name, :label, :options, keyword_init: true)

  # @api private
  # @todo Figure out a way to use a custom label, right now it takes it get rendered from the title.
  def self.default_fields_for(_work, fields: config.metadata_fields)
    fields.map do |field|
      Field.new(
        name: field.first,
        label: Hyrax::Renderers::AttributeRenderer.new(field.first, nil).label,
        options: field.last
      )
    end
  end

  def self.allinson_flex_fields_for(_work, fields: allinson_flex_fields)
    flex_fields = fields.map do |field|
      # currently only supports the faceted option
      # Why the `render_as:`? This was originally derived from Hyku default attributes
      # @see https://github.com/samvera/hyku/blob/c702844de4c003eaa88eb5a7514c7a1eae1b289e/app/views/hyrax/base/_attribute_rows.html.erb#L3
      options = field.indexing.include?('facetable') ? { render_as: :faceted } : nil
      Field.new(
        name: field.name,
        label: field.value,
        options: options
      )
    end
    # Adding collection metadata for display in the UV metadata pane
    if fields.where(name: 'collection').empty?
      collection_field = Field.new(name: :collection, label: 'Collection', options: nil)
      flex_fields << collection_field
    end
    flex_fields
  end

  def self.allinson_flex_fields
    # sql query method was refactored to active record
    # original query:
    # AllinsonFlex::ProfileProperty
    #   .find_by_sql(
    #     "SELECT DISTINCT allinson_flex_profile_texts.value AS label, " \
    #     "allinson_flex_profile_properties.name AS name " \
    #     "FROM allinson_flex_profile_properties " \
    #     "JOIN allinson_flex_profile_texts " \
    #     "ON allinson_flex_profile_properties.id = " \
    #       "allinson_flex_profile_texts.profile_property_id " \
    #     "WHERE allinson_flex_profile_texts.name = 'display_label'"
    #   )
    # In this ActiveRecord query, allinson_flex_profile_properties.indexing was added
    @allinson_flex_fields ||= AllinsonFlex::ProfileProperty
                              .joins(:texts)
                              .where(allinson_flex_profile_texts: { name: 'display_label' })
                              .distinct
                              .select(:name, :value, :indexing)
  end
end
