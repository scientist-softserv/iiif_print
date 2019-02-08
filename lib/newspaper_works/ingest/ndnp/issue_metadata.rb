module NewspaperWorks
  module Ingest
    module NDNP
      class IssueMetadata
        include NewspaperWorks::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :path, :doc

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
        def issue
          result = xpath("//mods:detail[@type='issue']/mods:number")
          return if result.size.zero?
          result.text
        end

        # Edition name, with fallback to edition number
        #   Edition name is optional ("caption" / "label"), but is
        #     the preferred notion of "edition" field in newspaper_works,
        #     and for the bibo:edition predicate.
        #   Edition number (aka "Edition Order" in NDNP specs) is mandatory
        #     but also arbitrary. We only use this as a fallback value,
        #     represented in String form, only when edition name is unavailable.
        # @return [String]
        def edition
          ed_name = xpath("//mods:detail[@type='edition']/mods:caption")
          return ed_name.text unless ed_name.size.zero?
          # fallback to edition number if name unavailable:
          xpath("//mods:detail[@type='edition']/mods:number").text
        end

        # Issue date (mandatory field) as ISO 8601 datestamp string
        # @return [String] (ISO-8601 date) publication date
        def publication_date
          xpath("//mods:originInfo/mods:dateIssued").text
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
