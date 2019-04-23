module NewspaperWorks
  module Ingest
    module NDNP
      class PageIngester
        attr_accessor :page, :issue, :target

        delegate :path, :dmdid, to: :page

        COPY_FIELDS = [
          :width,
          :height,
          :identifier
        ].freeze

        COPY_FIELDS_PLURALIZE = [
          :identifier
        ].freeze

        # @param page [NewspaperWorks::Ingest::NDNP::PageIngest]
        #   source page data
        # @param issue [NewspaperIssue]
        #   source issue data
        def initialize(page, issue)
          @page = page
          @issue = issue
          # target is to-be-created NewspaperPage:
          @target = nil
        end

        def ingest
          construct_page
          ingest_page_files
          link_reel
        end

        def construct_page
          @target = NewspaperPage.create
          @target.title = page_title
          copy_page_metadata
          link_issue
          @target.save!
        end

        # Ingest primary, derivative files; other derivatives including
        #   thumbnail, plain-text, json will be made by NewspaperWorks
        #   derivative service components as a consequence of commiting
        #   files assigned (via actor stack, via WorkFiles).
        def ingest_page_files
          work_files = NewspaperWorks::Data::WorkFiles.new(@target)
          page.files.each do |path|
            ext = path.downcase.split('.')[-1]
            if ['tif', 'tiff'].include?(ext)
              work_files.assign(path)
            else
              work_files.derivatives.assign(path)
            end
          end
          work_files.commit!
        end

        def link_reel
          reel_data = @page.container
          return if reel_data.nil?
          ingester = NewspaperWorks::Ingest::NDNP::ContainerIngester.new(
            reel_data,
            issue.publication
          )
          # find-or-create container, linked to publication:
          ingester.ingest
          # link target page to container asset for reel:
          ingester.link(@target)
        end

        private

          def link_issue
            issue.members << @target # page
            issue.save!
          end

          # Page title as issue title plus page title
          #   e.g. "ACME Tribune (1910-01-02): Page 2"
          # @return [String] composed page title
          def page_title
            ["#{issue.title.first}: Page #{@page.metadata.page_number}"]
          end

          def copy_page_metadata
            metadata = page.metadata
            # copy all fields with singular (non-repeatable) values on both
            #   target NewspaperIssue object, and metadata source:
            COPY_FIELDS.each do |fieldname|
              value = metadata.send(fieldname.to_s)
              pluralize = COPY_FIELDS_PLURALIZE.include?(fieldname)
              @target.send("#{fieldname}=", pluralize ? [value] : value)
            end
          end
      end
    end
  end
end
