require "iiif_print/engine"
require "iiif_print/errors"
require "iiif_print/jp2_image_metadata"
require "iiif_print/image_tool"
require "iiif_print/issue_pdf_composer"
require "iiif_print/text_extraction"
require "iiif_print/data"
require "iiif_print/configuration"
require "iiif_print/resource_fetcher"
require "iiif_print/page_derivative_service"
require "iiif_print/jp2_derivative_service"
require "iiif_print/pdf_derivative_service"
require "iiif_print/text_extraction_derivative_service"
require "iiif_print/text_formats_from_alto_service"
require "iiif_print/tiff_derivative_service"

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
    # TODO: This should be a class and not a string; but I don't know what that should just now be.
    pdf_splitter_job: "IiifPrint::DefaultPdfSplitterJob"
  }.freeze

  # This is the record level configuration for PDF split handling.
  ModelConfig = Struct.new(:pdf_split_child_model, *DEFAULT_MODEL_CONFIGURATION.keys, keyword_init: true)

  # This method is responsible for assisting in the configuration of a "model".
  #
  # @example
  #   class Book < ActiveFedora::Base
  #     include IiifPrint.model_configuration(pdf_split_child_model: Page)
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
      DEFAULT_MODEL_CONFIGURATION.each_pair do |key, value|
        kwargs[key] ||= value
      end

      define_method(:iiif_print_config) do
        @iiif_print_config ||= ModelConfig.new(**kwargs)
      end
    end
  end
end
