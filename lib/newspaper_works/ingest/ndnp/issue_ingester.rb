module NewspaperWorks
  module Ingest
    module NDNP
      class IssueIngester
        attr_accessor :batch, :issue, :target

        delegate :path, to: :issue

        COPY_FIELDS = [
          :lccn,
          :edition,
          :volume,
          :publication_date,
          :held_by,
          :issue_number
        ].freeze

        # @param issue [NewspaperWorks::Ingest::NDNP::IssueIngest]
        #   source issue data
        # @param batch [NewspaperWorks::Ingest::NDNP::BatchIngest, NilClass]
        #   source batch data (optional)
        def initialize(issue, batch = nil)
          @issue = issue
          @batch = batch
          @target = nil
        end

        def ingest
          construct_issue
          ingest_pages
        end

        def construct_issue
          create_issue
          find_or_create_linked_publication
        end

        def ingest_pages
          issue.each do |page|
            NewspaperWorks::Ingest::NDNP::PageIngester.new(page, @target).ingest
          end
        end

        private

          def page_ingester(page_data)
            NewspaperWorks::Ingest::NDNP::PageIngester.new(
              page_data,
              @target
            ).ingest
          end

          def issue_title
            meta = issue.metadata
            "#{meta.publication_title} (#{meta.publication_date})"
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
            @target.save!
          end

          # @param lccn [String] Library of Congress Control Number
          #   of Publication
          # @return [NewspaperTitle, NilClass] publication or nil if not found
          def find_publication(lccn)
            NewspaperTitle.where(lccn: lccn).first
          end

          def copy_publication_title(publication)
            complete_pubtitle = issue.metadata.publication_title.strip
            publication.title = [complete_pubtitle.split(/ \(/)[0]]
            place_name = complete_pubtitle.split(/ [\(]/)[1].split(')')[0]
            uri = NewspaperWorks::Ingest.geonames_place_uri(place_name)
            publication.place_of_publication = [uri] unless uri.nil?
          end

          def find_or_create_linked_publication
            lccn = issue.metadata.lccn
            publication = find_publication(lccn)
            publication = NewspaperTitle.create if publication.nil?
            copy_publication_title(publication)
            publication.lccn ||= lccn
            publication.members << @target
            publication.save!
          end
      end
    end
  end
end
