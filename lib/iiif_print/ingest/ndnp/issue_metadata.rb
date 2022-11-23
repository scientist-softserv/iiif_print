module IiifPrint
  module Ingest
    module NDNP
      class IssueMetadata
        include IiifPrint::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :path, :doc, :parent

        def initialize(path, parent = nil)
          @path = path
          @parent = parent
          @doc = nil
          load_doc
        end

        def inspect
          format(
            "<#{self.class}:0x000000000%<oid>x\n" \
              "\tpath: '#{path}',\n",
            oid: object_id << 1
          )
        end

        # LCCN (mandatory)
        # @return [String]
        def lccn
          xpath("//mods:identifier[@type='lccn']").text
        end

        # Volume number (optional)
        # @return [String,NilClass]
        def volume
          result = xpath("//mods:detail[@type='volume']/mods:number")
          return if result.size.zero?
          result.text
        end

        # Issue number (optional)
        # @return [String,NilClass]
        def issue_number
          result = xpath("//mods:detail[@type='issue']/mods:number")
          return if result.size.zero?
          result.text
        end

        # Edition name
        #   Edition name is optional ("caption" / "label") is optional
        #     in NDNP, but as it may be used as a label for readability.
        # @return [String,NilClass]
        def edition_name
          ed_name = xpath("//mods:detail[@type='edition']/mods:caption")
          return ed_name.text unless ed_name.size.zero?
        end

        # Edition name, with fallback to edition number (mandatory)
        # @return [String]
        def edition_number
          xpath("//mods:detail[@type='edition']/mods:number").text
        end

        # Issue date (mandatory field) as ISO 8601 datestamp string
        # @return [String] (ISO-8601 date) publication date
        def publication_date
          xpath("//mods:originInfo/mods:dateIssued").text
        end

        def publication_title
          # try from reel first
          reel = parent.nil? ? nil : parent.container
          return reel.metadata.title unless reel.nil?
          # fallback to parsing //mets/@LABEL
          label = xpath('//mets:mets/@LABEL').first
          v = label.nil? ? '' : label.value.split(/[,] [0-9]/)[0]
          # based on label convention:
          #   "ACME Times (Springfield, UT), 1911-01-25, First Edition"
          #   Returns the name and (*for now TBD*) place of publication
          #   as a string in parentheses.
          v.split(/, [0-9]/)[0]
        end

        # Original Source Repository (NDNP-mandatory)
        # @return [String]
        def held_by
          xpath("//mods:physicalLocation").first['displayLabel']
        end

        private

        def load_doc
          @doc = @parent.doc unless @parent.nil?
          @doc = Nokogiri::XML(File.open(path)) if @doc.nil?
        end
      end
    end
  end
end
