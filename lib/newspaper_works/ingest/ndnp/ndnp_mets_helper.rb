require 'nokogiri'

module NewspaperWorks
  module Ingest
    module NDNP
      # Mixin for mets-specific XPath and traversal of issue/page data
      module NDNPMetsHelper
        XML_NS = {
          mets: 'http://www.loc.gov/METS/',
          METS: 'http://www.loc.gov/METS/',
          mods: 'http://www.loc.gov/mods/v3',
          MODS: 'http://www.loc.gov/mods/v3',
          ndnp: 'http://www.loc.gov/ndnp',
          NDNP: 'http://www.loc.gov/ndnp'
        }.freeze

        # DRY XPath without repeatedly specifying default namespace urlmap
        def xpath(expr, context = nil)
          context ||= doc
          context.xpath(
            expr,
            **XML_NS
          )
        end

        def dmd_node
          xpath("//mets:dmdSec[@ID='#{dmdid}']")
        end

        def normalize_path(specified_path)
          return specified_path if specified_path.start_with?('/')
          basename = File.dirname(path)
          File.join(basename, specified_path)
        end

        # returns hash of "use" key string to path value
        # rubocop:disable Metrics/MethodLength (xpath is wordy!)
        def page_files
          # get pointers from structmap:
          file_group = xpath("//mets:structMap//mets:div[@DMDID='#{dmdid}']")
          result = xpath('mets:fptr', file_group).map do |fptr|
            file_id = fptr['FILEID']
            file_node = xpath(
              "//mets:fileSec//mets:fileGrp//mets:file[@ID='#{file_id}']"
            ).first
            [
              file_node['USE'],
              xpath('mets:FLocat', file_node).first.attribute_with_ns(
                'href',
                'http://www.w3.org/1999/xlink'
              ).to_s
            ]
          end
          result.to_h
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
