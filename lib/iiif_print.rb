require "iiif_print/engine"
require "iiif_print/errors"
require "iiif_print/jp2_image_metadata"
require "iiif_print/image_tool"
require "iiif_print/issue_pdf_composer"
require "iiif_print/text_extraction"
require "iiif_print/data"
require "iiif_print/configuration"
require "iiif_print/resource_fetcher"

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
end
