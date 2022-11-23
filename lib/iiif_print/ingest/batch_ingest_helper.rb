require 'find'

module NewspaperWorks
  module Ingest
    # mixin module for common batch ingest steps
    module BatchIngestHelper
      MEDIA_PDF = 'pdf'.freeze
      MEDIA_IMAGE = 'image'.freeze
      def detect_media(path)
        result = MEDIA_PDF # default
        Find.find(path) do |p|
          result = MEDIA_IMAGE if p.end_with?('jp2') || /TIF[F]?$/i.match(p)
        end
        result
      end

      def lccn_from_path(path)
        File.basename(path)
      end

      def normalize_lccn(v)
        p = /^[A-Za-z]{0,3}[0-9]{8}([0-9]{2})?$/
        v = v.gsub(/\s+/, '').downcase.slice(0, 13)
        raise ArgumentError, "LCCN appears invalid: #{v}" unless p.match(v)
        v
      end

      def issue_title(issue_data)
        issue_data.title
      end

      def copy_issue_metadata(source, target)
        target.title = issue_title(source)
        target.lccn = source.lccn
        target.publication_date = source.publication_date
        target.edition_number = source.edition_number
      end

      def attach_file(work, path)
        NewspaperWorks::Data::WorkFiles.assign!(to: work, path: path)
      end
    end
  end
end
