require "iiif_print/engine"
require "iiif_print/errors"
require "iiif_print/jp2_image_metadata"
require "iiif_print/image_tool"
require "iiif_print/issue_pdf_composer"
require "iiif_print/text_extraction"
require "iiif_print/data"
require "iiif_print/configuration"
require "iiif_print/resource_fetcher"

# Newspaper works modules
module IiifPrint
  def self.config(&block)
    @config ||= IiifPrint::Configuration.new
    yield @config if block
    @config
  end
end
