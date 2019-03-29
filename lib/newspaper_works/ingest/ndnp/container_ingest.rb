module NewspaperWorks
  module Ingest
    module NDNP
      class ContainerIngest
        # Enumerable of IssueIngest objects for issues in pages
        include Enumerable
        include NewspaperWorks::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :path, :doc, :dmdids, :issue_paths

        def initialize(path)
          @path = path
          @doc = nil
          @metadata = nil
          # identifiers of control images, which we make accessible, but are
          #   not the primary focus of enumeration:
          @dmdids = nil
          @issue_paths = []
          load_doc
        end

        def inspect
          format(
            "<#{self.class}:0x000000000%<oid>x\n" \
              "\tpath: '#{path}',\n",
            oid: object_id << 1
          )
        end

        def identifier
          metadata.reel_number
        end

        # Return control image as PageIngest object.
        #   These objects will not have pagination/sequence data, but
        #   will provide an equivalent programmatic interface for file access
        #   of control images, as one would access normal page files.
        # @return [NewspaperWorks::Ingest::NDNP::PageIngest]
        def page_by_dmdid(dmdid)
          NewspaperWorks::Ingest::NDNP::PageIngest.new(@path, dmdid, self)
        end

        # Get IssueIngest object, given path to its XML
        # return [NewspaperWorks::Ingest::NDNP::IssueIngest]
        def issue_by_path(path)
          NewspaperWorks::Ingest::NDNP::IssueIngest.new(path)
        end

        def each
          @issue_paths.each do |path|
            yield issue_by_path(path)
          end
        end

        def size
          @issue_paths.size
        end

        def metadata
          return @metadata unless @metadata.nil?
          @metadata = NewspaperWorks::Ingest::NDNP::ContainerMetadata.new(
            path,
            self
          )
        end

        private

          def load_doc
            @doc = Nokogiri::XML(File.open(path)) if @doc.nil?
            page_divs = doc.xpath(
              "//mets:structMap/mets:div[@TYPE='np:reel']/" \
                "mets:div[@TYPE='np:target']",
              mets: 'http://www.loc.gov/METS/'
            )
            # identifiers for reel control images:
            @dmdids = page_divs.map { |div| div.attr('DMDID') }
            load_issue_paths
          end

          # Load instance attribute for issue paths,
          #   based on listing of directory in which reel XML is present.
          #   This is done without context of batch xml,
          #   with file name expectations based on convention,
          #   as expressed in NDNP technical guidelines,
          #   which presume that the issue XML file name will (sans extension)
          #   match directory name for the issue, in date+edition syntax.
          def load_issue_paths
            issue_dir_paths = Dir["#{File.dirname(path)}/*/"].select do |v|
              !File.basename(v).match(/^[0-9]+$/).nil?
            end
            @issue_paths = issue_dir_paths.map do |path|
              File.join(path, "#{File.basename(path)}.xml")
            end
          end
      end
    end
  end
end
