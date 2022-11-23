require 'nokogiri'

module IiifPrint
  module Ingest
    module NDNP
      class BatchXMLIngest
        include Enumerable
        include IiifPrint::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :container_paths, :issue_paths, :path

        delegate :size, to: :issue_paths

        def initialize(path)
          @path = path
          load_doc
          @container_paths = xpath('//ndnp:batch//ndnp:reel').map do |e|
            normalize_path(e.text)
          end
          @issue_paths = xpath('//ndnp:batch//ndnp:issue').map do |e|
            normalize_path(e.text)
          end
        end

        def name
          xpath('//ndnp:batch').first.attributes['name'].value
        end

        def get(path)
          return get_issue(path) if issue_paths.include?(path)
          get_container(path)
        end

        def issues
          issue_paths.map { |path| get(path) }
        end

        def containers
          container_paths.map { |path| get(path) }
        end

        def each
          @issue_paths.each do |path|
            yield get_issue(path)
          end
        end

        private

        def get_issue(path)
          IiifPrint::Ingest::NDNP::IssueIngest.new(path)
        end

        def get_container(path)
          IiifPrint::Ingest::NDNP::ContainerIngest.new(path)
        end

        def xpath(expr)
          ns = {
            ndnp: 'http://www.loc.gov/ndnp',
            NDNP: 'http://www.loc.gov/ndnp'
          }
          @doc.xpath(expr, **ns)
        end

        def load_doc
          @doc = Nokogiri::XML(File.open(path))
        end
      end
    end
  end
end
