module NewspaperWorks
  module Ingest
    module NDNP
      class IssueIngest
        include Enumerable
        include NewspaperWorks::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :path, :doc, :dmdids

        def initialize(path)
          @path = path
          @doc = nil
          @metadata = nil
          # Enumeration based on list of DMDID loaded by load_doc
          @dmdids = nil
          load_doc
          # cache dmdid -> PageIngest
          @page_cache = {}
        end

        def inspect
          format(
            "<#{self.class}:0x000000000%<oid>x\n" \
              "\tpath: '#{path}',\n",
            oid: object_id << 1
          )
        end

        def identifier
          metadata.lccn
        end

        def page_by_dmdid(dmdid)
          return @page_cache[dmdid] if @page_cache.key?(dmdid)
          p = NewspaperWorks::Ingest::NDNP::PageIngest.new(@path, dmdid, self)
          @page_cache[dmdid] = p
          p
        end

        def page_by_sequence_number(n)
          page_by_dmdid(
            doc.xpath(
              "//mods:extent//mods:start[text()='#{n}']",
              mets: 'http://www.loc.gov/METS/',
              mods: 'http://www.loc.gov/mods/v3'
            ).first.ancestors('dmdSec').first['ID']
          )
        end

        def each
          @dmdids.each do |dmdid|
            yield page_by_dmdid(dmdid)
          end
        end

        def size
          @dmdids.size
        end

        def metadata
          return @metadata unless @metadata.nil?
          @metadata = NewspaperWorks::Ingest::NDNP::IssueMetadata.new(
            path,
            self
          )
        end

        private

          def load_doc
            @doc = Nokogiri::XML(File.open(path)) if @doc.nil?
            page_divs = doc.xpath(
              "//mets:structMap//mets:div[@TYPE='np:page']",
              mets: 'http://www.loc.gov/METS/'
            )
            @dmdids = page_divs.map { |div| div.attr('DMDID') }
          end
      end
    end
  end
end
