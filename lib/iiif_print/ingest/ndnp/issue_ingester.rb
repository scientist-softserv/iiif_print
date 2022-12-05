module IiifPrint
  module Ingest
    module NDNP
      class IssueIngester
        include IiifPrint::Logging
        include IiifPrint::Ingest::NDNP::NDNPAssetHelper
        include IiifPrint::Ingest::PubFinder

        attr_accessor :issue, :target, :opts

        delegate :path, to: :issue

        COPY_FIELDS = [
          :lccn,
          :edition_number,
          :edition_name,
          :volume,
          :publication_date,
          :held_by,
          :issue_number
        ].freeze

        # @param issue [IiifPrint::Ingest::NDNP::IssueIngest]
        #   source issue data
        # @param opts [Hash]
        #   ingest options, e.g. administrative metadata
        def initialize(issue, opts = {})
          @issue = issue
          @opts = opts
          @target = nil
          configure_logger('ingest')
        end

        def ingest
          construct_issue
          ingest_pages
          IiifPrint::ComposeIssuePDFJob.perform_later(@target)
        end

        def construct_issue
          create_issue
          find_or_create_linked_publication
        end

        def ingest_pages
          issue.each do |page|
            page_ingester(page).ingest
          end
        end

        private

        def page_ingester(page_data)
          IiifPrint::Ingest::NDNP::PageIngester.new(
            page_data,
            @target,
            @opts
          )
        end

        def publication_date
          parsed = DateTime.iso8601(issue.metadata.publication_date)
          parsed.strftime('%B %-d, %Y')
        end

        def publication_title(issue)
          issue.metadata.publication_title.strip.split(/ \(/)[0]
        end

        def issue_title
          "#{publication_title(issue)}: #{publication_date}"
        end

        def copy_issue_metadata
          metadata = issue.metadata
          # set (required, plural) title from single value obtained from reel:
          @target.title = [issue_title]
          # copy all fields with singular (non-repeatable) values on both
          #   target NewspaperIssue object, and metadata source:
          COPY_FIELDS.each do |fieldname|
            @target.send("#{fieldname}=", metadata.send(fieldname.to_s))
          end
        end

        def create_issue
          @target = NewspaperIssue.create
          copy_issue_metadata
          assign_administrative_metadata
          @target.save!
          write_log("Saved metadata to new NewspaperIssue #{@target.id}")
        end

        def find_or_create_linked_publication
          title = publication_title(issue)
          lccn = issue.metadata.lccn
          find_or_create_publication_for_issue(@target, lccn, title, @opts)
        end
      end
    end
  end
end
