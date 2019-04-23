require 'faraday'
require 'nokogiri'
require 'uri'
require 'newspaper_works/ingest/pdf_images'
require 'newspaper_works/ingest/pdf_pages'
require 'newspaper_works/ingest/base_ingest'
require 'newspaper_works/ingest/ndnp'
require 'newspaper_works/ingest/newspaper_page_ingest'
require 'newspaper_works/ingest/newspaper_issue_ingest'

module NewspaperWorks
  # Module for Ingest adapters that import files into model objects
  module Ingest
    # Get Geonames URI for closest place match
    #   Requires Qa::Authorities::Geonames.username is set, likely via
    #   `Hyrax.config.geonames_username=` setter in
    #   config/initializers/hyrax.rb of consuming app.
    # @param place_name [String] Name of place as human-readable text
    # @return [String, NilClass] URI to Geonames RDF or nil
    def self.geonames_place_uri(place_name)
      username = Qa::Authorities::Geonames.username
      return if username.nil? || username.empty?
      query = URI.encode(place_name)
      geo_qs = "q=#{query}&username=#{username}"
      url = "http://api.geonames.org/search?#{geo_qs}"
      resp = Faraday.get url
      doc = Nokogiri.XML(resp.body)
      geonames_id = doc.xpath('//geonames/geoname[1]/geonameId').first
      return if geonames_id.nil?
      "http://sws.geonames.org/#{geonames_id.text}/"
    end
  end
end
