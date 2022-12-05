require 'nokogiri'

module IiifPrint
  module Ingest
    module NDNP
      class PageMetadata
        # mixin convenience methods for NDNP XML, plus XML_NS hash
        include IiifPrint::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :path, :dmdid, :doc

        def initialize(path = nil, parent = nil, dmdid = nil)
          raise ArgumentError, 'No context provided' if path.nil? && parent.nil?
          @path = path
          @parent = parent
          @dmdid = dmdid
          @doc = nil
          load_doc
        end

        def inspect
          format(
            "<#{self.class}:0x000000000%<oid>x\n" \
              "\tpath: '#{path}',\n" \
              "\tdmdid: '#{dmdid}' ...>",
            oid: object_id << 1
          )
        end

        # Printed page number, if printed; optional field in NDNP spec.
        #   "Number" is used liberally, and may contain both alpha
        #   and numeric characters.  As such, return value is String.
        #
        #   If NDNP issue data fails to provide an explicitly
        #   human-readable page number, fallback to sequence
        #   number, in String form.
        #
        # @return [String, NilClass] Page "number" string
        def page_number
          detail = dmd_node.xpath(
            ".//mods:mods//mods:detail[@type='page number']",
            **XML_NS
          )
          if detail.size.zero?
            fallback = page_sequence_number
            return fallback.nil? ? nil : fallback.to_s
          end
          detail.xpath("mods:number", **XML_NS).first.text
        end

        # Page sequence number, indexical to order in issue.
        #   "Number" here is one-indexed positive integer, position in
        #   issue.  Mandatory for page of issue, nil for page of reel.
        # @return [Integer,NilClass] Page sequence number, positive integer
        def page_sequence_number
          detail = dmd_node.xpath(
            ".//mods:mods//mods:extent[@unit='pages']",
            **XML_NS
          )
          node = detail.xpath("mods:start", **XML_NS).first
          node.text.to_i unless node.nil?
        end

        # Extract identifier from page ALTO, based on file name.
        #   XML parsing of big documents are expensive, so use regex to
        #   scan for fileName element, and return its value.
        # @return [String,NilClass] file name or path, or nil.
        def identifier
          matches = page_alto.scan(/<fileName>([^<]*)<\/fileName>/).first
          matches.size.zero? ? nil : stripped_filename(matches[0])
        end

        def height
          alto_page_meta('HEIGHT').to_i
        end

        def width
          alto_page_meta('WIDTH').to_i
        end

        private

        # filename stripped of base path and file extension
        def stripped_filename(path)
          File.basename(path).split('.')[0]
        end

        def load_doc
          @doc = @parent.doc unless @parent.nil?
          @doc = Nokogiri::XML(File.open(path)) if @doc.nil?
        end

        def alto_path
          specified_path = page_files['ocr']
          normalize_path(specified_path)
        end

        def page_alto
          File.read(alto_path)
        end

        def alto_page_meta(key)
          matches = page_alto.scan(/(<Page [^>]*>)/).first
          return if matches.size.zero?
          # parse xml <Page> start tag fragment, get attributes:
          page_tag = Nokogiri::XML(matches[0]).root
          page_tag[key]
        end
      end
    end
  end
end
