require 'newspaper_works/logging'

module NewspaperWorks
  module Ingest
    module NDNP
      # rubocop:disable Metrics/ClassLength
      class PageIngester
        include NewspaperWorks::Logging
        include NewspaperWorks::Ingest::NDNP::NDNPAssetHelper

        attr_accessor :page, :issue, :target, :opts

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
        # @param opts [Hash]
        #   ingest options, e.g. administrative metadata
        def initialize(page, issue, opts = {})
          @page = page
          @issue = issue
          @opts = opts
          # target is to-be-created NewspaperPage:
          @target = nil
          @work_files = nil
          configure_logger('ingest')
        end

        def ingest
          construct_page
          ingest_page_files
          link_reel
        end

        def construct_page
          @target = NewspaperPage.create!(title: page_title)
          write_log(
            "Created NewspaperPage work #{@target.id} "\
            "with title '#{@target.title[0]}'"
          )
          copy_page_metadata
          assign_administrative_metadata
          link_issue
          @target.save!
          write_log("Saved metadata to NewspaperPage work #{@target.id}")
        end

        # Ingest primary, derivative files; other derivatives including
        #   thumbnail, plain-text, json will be made by NewspaperWorks
        #   derivative service components as a consequence of commiting
        #   files assigned (via actor stack, via WorkFiles).
        def ingest_page_files
          @work_files = NewspaperWorks::Data::WorkFiles.new(@target)
          page.files.each do |path|
            ext = path.downcase.split('.')[-1]
            if ['tif', 'tiff'].include?(ext)
              ingest_primary_file(path)
            else
              ingest_derivative_file(path)
            end
          end
          write_log("Beginning file attachment process (WorkFiles.commit!) "\
            "for work #{@target.id}")
          @work_files.commit!
        end

        def link_reel
          reel_data = @page.container
          return if reel_data.nil?
          ingester = NewspaperWorks::Ingest::NDNP::ContainerIngester.new(
            reel_data,
            issue.publication,
            @opts
          )
          # find-or-create container, linked to publication:
          ingester.ingest
          # link target page to container asset for reel:
          ingester.link(@target)
        end

        private

          def ingest_primary_file(path)
            unless File.exist?(path)
              pdf_path = page.files.select { |p| p.end_with?('pdf') }[0]
              # make and get TIFF path (to generated tmp file):
              path = make_tiff(pdf_path)
            end
            write_log("Assigned primary file to work #{@target.id}, #{path}")
            @work_files.assign(path)
          end

          def ingest_derivative_file(path)
            write_log("Assigned derivative file to work #{@target.id}, #{path}")
            @work_files.derivatives.assign(path)
          end

          def link_issue
            issue.ordered_members << @target # page
            issue.save!
            write_log(
              "Linked NewspaperIssue work #{issue.id} "\
              "to NewspaperPage work #{@target.id}"
            )
          end

          # dir whitelist
          def whitelist
            Hyrax.config.whitelisted_ingest_dirs
          end

          # Generate TIFF in temporary file, return its path, given path to PDF
          # @param pdf_path [String] path to single-page PDF
          # @return [String] path to generated TIFF
          def make_tiff(pdf_path)
            write_log(
              "Creating TIFF from PDF in lieu of missing for work "\
              " (#{@target.id})",
              Logger::WARN
            )
            whitelist.push(Dir.tmpdir) unless whitelist.include?(Dir.tmpdir)
            NewspaperWorks::Ingest::PdfPages.new(pdf_path).to_a[0]
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
      # rubocop:enable Metrics/ClassLength
    end
  end
end
