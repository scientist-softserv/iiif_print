module NewspaperWorks
  module Ingest
    class PDFIssueIngester
      # CLI constructor, related class methods:
      extend NewspaperWorks::Ingest::FromCommand

      include NewspaperWorks::Ingest::PubFinder
      include NewspaperWorks::Logging

      attr_accessor :path, :lccn, :publication, :opts, :issues

      def initialize(path, opts = {})
        @path = path
        lccn = opts[:lccn]
        @lccn = normalize_lccn(lccn.nil? ? lccn_from_path(path) : lccn)
        # get publication info for LCCN from authority web service:
        @publication = NewspaperWorks::Ingest::PublicationInfo.new(@lccn)
        # issues for publication, as enumerable of PDFIssue
        @issues = NewspaperWorks::Ingest::PDFIssues.new(path, publication)
        @opts = opts
        configure_logger('ingest')
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

      def create_issue(issue_data)
        issue = NewspaperIssue.create
        copy_issue_metadata(issue_data, issue)
        NewspaperWorks::Ingest.assign_administrative_metadata(
          issue,
          @opts
        )
        issue.save!
        write_log(
          "Created new NewspaperIssue work with date, lccn, edition metadata:"\
          "\n"\
          "\tLCCN: #{@lccn}\n"\
          "\tPublication Date: #{issue_data.publication_date}\n"\
          "\tEdition number: #{issue_data.edition_number}"
        )
        find_or_create_publication_for_issue(
          issue,
          @lccn,
          @publication.title,
          @opts
        )
        issue
      end

      def copy_issue_metadata(source, target)
        target.title = issue_title(source)
        target.lccn = source.lccn
        target.publication_date = source.publication_date
        target.edition_number = source.edition_number
      end

      def ingest_pdf(issue, path)
        # ingest primary PDF for issue:
        attachment = NewspaperWorks::Data::WorkFiles.of(issue)
        attachment.assign(path)
        attachment.commit!
        # queue page creation job:
        CreateIssuePagesJob.perform_later(issue, [path], nil, nil)
      end

      def ingest
        write_log("Beginning PDF issue(s) batch ingest for #{@path}")
        write_log("\tPublication: #{@publication.title} (LCCN: #{@lccn})")
        @issues.each do |path, issue_data|
          issue = create_issue(issue_data)
          ingest_pdf(issue, path)
        end
        write_log(
          "PDF issue ingest completed for LCCN #{@lccn}. Asyncrhonous jobs "\
          "may still be creating derivatives for issue, and child page works."
        )
      end
    end
  end
end
