require "newspaper_works/engine"
require "newspaper_works/errors"
require "newspaper_works/jp2_image_metadata"
require "newspaper_works/image_tool"
require "newspaper_works/ingest"
require "newspaper_works/issue_pdf_composer"
require "newspaper_works/text_extraction"
require "newspaper_works/data"
require "newspaper_works/configuration"
require "newspaper_works/page_finder"
require "newspaper_works/logging"
require "newspaper_works/resource_fetcher"

# Newspaper works modules
module NewspaperWorks
  def self.config(&block)
    @config ||= NewspaperWorks::Configuration.new
    yield @config if block
    @config
  end
end
