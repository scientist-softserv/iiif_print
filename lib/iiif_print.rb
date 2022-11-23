require "iiif_print/engine"
require "iiif_print/errors"
require "iiif_print/jp2_image_metadata"
require "iiif_print/image_tool"
require "iiif_print/ingest"
require "newspaper_works/issue_pdf_composer"
require "newspaper_works/text_extraction"
require "newspaper_works/data"
require "newspaper_works/configuration"
require "newspaper_works/page_finder"
require "newspaper_works/logging"
require "newspaper_works/resource_fetcher"

# Newspaper works modules
module IiifPrint
  def self.config(&block)
    @config ||= IiifPrint::Configuration.new
    yield @config if block
    @config
  end
end
