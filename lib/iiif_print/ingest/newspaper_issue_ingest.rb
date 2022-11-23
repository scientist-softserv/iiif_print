module IiifPrint
  module Ingest
    class NewspaperIssueIngest < BaseIngest
      @configured = false

      class << self
        def configure
          return if @configured == true
          # PDF ingest may save page images to /tmp (via Dir.tmpdir), which
          # needs whitelisting for use by IiifPrint::Data::WorkFiles.commit!
          # via Hyrax CreateWithRemoteFilesActor:
          whitelist = Hyrax.config.whitelisted_ingest_dirs
          whitelist.push(Dir.tmpdir) unless whitelist.include?(Dir.tmpdir)
          @configured = true
        end
      end

      def import
        # first, handle the PDF itself on the issue...
        super
        # ...then create child works from split pages
        create_child_pages
      end

      # Creates child pages with attached TIFF masters, can be called by
      #   `import`, or independently if `load` is called first.  The
      #   latter is appropriate if framework is already handling the
      #   NewspaperIssue file attachment (e.g. Hyrax upload via browser).
      def create_child_pages
        self.class.configure
        pages = IiifPrint::Ingest::PdfPages.new(path).to_a
        pages.each_with_index do |tiffpath, idx|
          page = new_child_page_with_file(tiffpath, idx)
          @work.ordered_members << page
        end
        @work.save!(validate: false) unless pages.empty?
      end

      def new_child_page_with_file(tiffpath, idx)
        page_number = idx + 1
        page = NewspaperPage.new
        page.title = ["#{@work.title.first}: Page #{page_number}"]
        # technically, a sequence number distinct from displayed page number
        page.page_number = page_number.to_s
        # Set depositor and admin-set id:
        page.depositor = @work.depositor
        page.admin_set_id = @work.admin_set_id
        # copying permissions also by effect copies visibility:
        page.permissions_attributes = @work.permissions.map(&:to_hash)
        NewspaperPageIngest.new(page).ingest(tiffpath)
        page.save!
        page
      end
    end
  end
end
