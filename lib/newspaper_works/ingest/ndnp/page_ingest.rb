module NewspaperWorks
  module Ingest
    module NDNP
      class PageIngest
        include NewspaperWorks::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :path, :dmdid, :doc, :files

        def initialize(path = nil, dmdid = nil, parent = nil)
          raise ArgumentError, 'No path provided' if path.nil?
          @path = path
          @dmdid = dmdid
          @doc = nil
          @parent = parent
          @metadata = nil
          load_doc
          @files = page_files.values.map(&method(:normalize_path))
        end

        def inspect
          format(
            "<#{self.class}:0x000000000%<oid>x\n" \
              "\tpath: '#{path}',\n" \
              "\tdmdid: '#{dmdid}' ...>",
            oid: object_id << 1
          )
        end

        def metadata
          return @metadata unless @metadata.nil?
          @metadata = NewspaperWorks::Ingest::NDNP::PageMetadata.new(
            path,
            self,
            dmdid
          )
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
