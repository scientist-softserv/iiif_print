module NewspaperWorks
  module Ingest
    module NDNP
      # rubocop:disable Metrics/ClassLength
      class IssueIngester
        include NewspaperWorks::Logging
        include NewspaperWorks::Ingest::NDNP::NDNPAssetHelper

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

        # @param issue [NewspaperWorks::Ingest::NDNP::IssueIngest]
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
            NewspaperWorks::Ingest::NDNP::PageIngester.new(
              page_data,
              @target,
              @opts
            )
          end

          def publication_date
            parsed = DateTime.iso8601(issue.metadata.publication_date)
            parsed.strftime('%B %-d, %Y')
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

          # @param lccn [String] Library of Congress Control Number
          #   of Publication
          # @return [NewspaperTitle, NilClass] publication or nil if not found
          def find_publication(lccn)
            NewspaperTitle.where(lccn: lccn).first
          end

          # Singular string title for publication, without place description
          # @return [String]
          def publication_title(issue)
            issue.metadata.publication_title.strip.split(/ \(/)[0]
          end

          def copy_publication_title(publication)
            complete_pubtitle = issue.metadata.publication_title.strip
            publication.title = [publication_title(issue)]
            place_name = complete_pubtitle.split(/ [\(]/)[1].split(')')[0]
            uri = NewspaperWorks::Ingest.geonames_place_uri(place_name)
            publication.place_of_publication = [uri] unless uri.nil?
          end

          def create_publication(lccn)
            publication = NewspaperTitle.create
            copy_publication_title(publication)
            publication.lccn ||= lccn
            assign_administrative_metadata(publication)
            publication.save!
            write_log(
              "Created NewspaperTitle work #{publication.id} for LCCN #{lccn}"
            )
            publication
          end

          def find_or_create_linked_publication
            lccn = issue.metadata.lccn
            publication = find_publication(lccn)
            unless publication.nil?
              write_log(
                "Found existing NewspaperTitle #{publication.id}, LCCN #{lccn}"
              )
            end
            publication = create_publication(lccn) if publication.nil?
            publication.ordered_members << @target
            publication.save!
            write_log(
              "Linked NewspaperIssue #{@target.id} to "\
              "NewspaperTitle work #{publication.id}"
            )
          end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
