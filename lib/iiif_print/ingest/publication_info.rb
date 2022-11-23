require 'faraday'
require 'nokogiri'
require 'uri'

module IiifPrint
  module Ingest
    class PublicationInfo
      attr_accessor :implementation, :lccn

      def initialize(lccn)
        @lccn = lccn
        @implementation = nil
        load
      end

      def load_chronam_fallback
        @implementation = ChronAmPublicationInfo.new(@lccn)
      end

      def load
        @implementation = LCPublicationInfo.new(@lccn)
        @implementation.load
        # Empty mods is equivalent to 404 for LCCN in LC Catalog:
        load_chronam_fallback if @implementation.empty?
      end

      def respond_to_missing?(symbol, include_priv = false)
        @implementation.respond_to?(symbol, include_priv)
      end

      def method_missing(method, *args, &block)
        # proxy call to underlying implementation:
        if respond_to_missing?(method)
          return @implementation.send(
            method,
            *args,
            &block
          )
        end
        super
      end
    end
  end
end
