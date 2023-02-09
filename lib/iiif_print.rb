require "iiif_print/engine"
require "iiif_print/errors"
require "iiif_print/jp2_image_metadata"
require "iiif_print/image_tool"
require "iiif_print/catalog_search_builder"
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
require "iiif_print/jobs/child_works_from_pdf_job"
require "iiif_print/jobs/create_relationships_job"
require "iiif_print/split_pdfs/pages_into_images_service"

module IiifPrint
  extend ActiveSupport::Autoload
  autoload :Configuration

  ##
  # @api public
  # Exposes the IiifPrint configuration.
  #
  # In the below examples, you would add the code to a `config/initializers/iiif_print_config.rb` file
  # inside your application
  #
  # @example
  #   IiifPrint.config do |config|
  #     config.work_types_for_derivative_service = [GenericWork, Image]
  #   end
  # @yield [IiifPrint::Configuration] if a block is passed
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
    pdf_splitter_service: IiifPrint::SplitPdfs::PagesIntoImagesService,
    derivative_service_plugins: [
      IiifPrint::JP2DerivativeService,
      IiifPrint::PDFDerivativeService,
      IiifPrint::TextExtractionDerivativeService,
      IiifPrint::TIFFDerivativeService
    ]
  }.freeze

  # This is the record level configuration for PDF split handling.
  ModelConfig = Struct.new(:pdf_split_child_model, *DEFAULT_MODEL_CONFIGURATION.keys, keyword_init: true)

  # This method is responsible for assisting in the configuration of a "model".
  #
  # @example
  #   class Book < ActiveFedora::Base
  #     include IiifPrint.model_configuration(
  #       pdf_split_child_model: Page,
  #       derivative_service_plugins: [
  #         IiifPrint::TIFFDerivativeService
  #       ]
  #     )
  #   end
  #
  # @param kwargs [Hash<Symbol,Object>] the configuration values that overrides the
  #        DEFAULT_MODEL_CONFIGURATION.
  #
  # @return [Module]
  #
  # @see IiifPrint::DEFAULT_MODEL_CONFIGURATION
  # @todo Because not every job will split PDFs and write to a child model, we may need a gem level
  #       fallback.
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
                                 fields: default_fields_for(work),
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
        label: Hyrax::Renderers::AttributeRenderer.new(field, nil).label,
        options: field.last
      )
    end
  end
end
