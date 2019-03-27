require "newspaper_works/engine"
require "newspaper_works/ingest"
require "newspaper_works/text_extraction"
require "newspaper_works/data"
require "newspaper_works/configuration"

# Newspaper works modules
module NewspaperWorks
  def self.config(&block)
    @config ||= NewspaperWorks::Configuration.new
    yield @config if block
    @config
  end
end
