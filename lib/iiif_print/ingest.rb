require 'faraday'
require 'nokogiri'
require 'uri'
require 'iiif_print/ingest/from_command'
require 'iiif_print/ingest/base_publication_info'
require 'iiif_print/ingest/chronam_publication_info'
require 'iiif_print/ingest/lc_publication_info'
require 'iiif_print/ingest/publication_info'
require 'iiif_print/ingest/pub_finder'
require 'iiif_print/ingest/pdf_images'
require 'iiif_print/ingest/named_issue_metadata'
require 'iiif_print/ingest/path_enumeration'
require 'iiif_print/ingest/pdf_issue'
require 'iiif_print/ingest/pdf_issues'
require 'iiif_print/ingest/batch_ingest_helper'
require 'iiif_print/ingest/batch_issue_ingester'
require 'iiif_print/ingest/pdf_pages'
require 'iiif_print/ingest/issue_images'
require 'iiif_print/ingest/page_image'
require 'iiif_print/ingest/image_ingest_issues'
require 'iiif_print/ingest/base_ingest'
require 'iiif_print/ingest/ndnp'
require 'iiif_print/ingest/newspaper_page_ingest'
require 'iiif_print/ingest/newspaper_issue_ingest'

module IiifPrint
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
      place_name = place_name.delete('.').split(/[\[\(]/)[0].strip
      query = URI.encode(place_name)
      geo_qs = "q=#{query}&username=#{username}"
      url = "http://api.geonames.org/search?#{geo_qs}"
      resp = IiifPrint::ResourceFetcher.get url
      doc = Nokogiri.XML(resp['body'])
      geonames_id = doc.xpath('//geonames/geoname[1]/geonameId').first
      return if geonames_id.nil?
      "http://sws.geonames.org/#{geonames_id.text}/"
    end

    # Normalize publication title from catalog data
    #   Presently strips trailing period
    # @param title [String]
    # @return [String] normalized title
    def self.normalize_title(title)
      title&.strip&.sub(/[.]+$/, '')
    end

    # Get publication metadata from LC catalog MODS data, if available,
    #   and from ChronAm, as a fallback.
    # @param lccn [String] Library of Congress Control number for publication
    # @return [IiifPrint::Ingest::PublicationInfo] proxy to metadata
    #   source, an object for accessors for publication fields.
    def self.publication_metadata(lccn)
      PublicationInfo.new(lccn)
    end

    def self.find_admin_set(admin_set = nil)
      return admin_set if admin_set.class == AdminSet
      admin_set = AdminSet::DEFAULT_ID if admin_set.nil?
      begin
        AdminSet.find(admin_set)
      rescue
        # only create if default admin set
        raise unless admin_set == AdminSet::DEFAULT_ID
        AdminSet.find(AdminSet.find_or_create_default_admin_set_id)
      end
    end

    def self.assign_administrative_metadata(work, opts = {})
      work.depositor = opts.fetch(:email, User.batch_user.user_key)
      work.admin_set = find_admin_set(opts.fetch(:admin_set, nil))
      work.visibility = opts.fetch(:visibility, 'open')
      work.resource_type = ['Newspapers']
      work.date_modified ||= Hyrax::TimeService.time_in_utc
      work.date_uploaded ||= work.date_modified
      work.state = RDF::URI(
        'http://fedora.info/definitions/1/0/access/ObjState#active'
      )
    end
  end
end
