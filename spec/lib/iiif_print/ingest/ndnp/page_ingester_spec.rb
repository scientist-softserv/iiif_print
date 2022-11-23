require 'spec_helper'
require 'ndnp_shared'
require 'misc_shared'

RSpec.describe IiifPrint::Ingest::NDNP::PageIngester do
  include_context "ndnp fixture setup"
  include_context "shared setup"

  # use FactoryBot issue factory for a NewspaperIssue object for page:
  let(:issue) { create(:newspaper_issue) }

  # We need page source data as PageIngest
  let(:page_data) do
    IiifPrint::Ingest::NDNP::PageIngest.new(issue1, 'pageModsBib8')
  end

  let(:metadata) { page_data.metadata }

  # PageIngester adapter does the work we are testing:
  let(:adapter) { described_class.new(page_data, issue) }

  describe "adapter and asset construction" do
    it "constructs adapter with page source, issue context" do
      expect(adapter.page).to be page_data
      expect(adapter.issue).to be issue
      expect(adapter.path).to eq page_data.path
    end

    it "constructs NewspaperPage with adapter" do
      # construct_page is ingest of metadata only, without importing files:
      adapter.construct_page
      page = adapter.target
      expect(page).to be_a NewspaperPage
      expect(page.id).not_to be_nil
      expect(issue.members).to include page
      expect(issue.ordered_members.to_a).to include page
    end

    it "constructs adapter with hash options" do
      user = User.batch_user.user_key
      adapter = described_class.new(
        page_data,
        issue,
        depositor: user
      )
      expect(adapter.opts[:depositor]).to eq user
    end
  end

  describe "metadata access/setting" do
    let(:expected_title) do
      "#{issue.title.first}: Page #{metadata.page_number}"
    end

    it "sets default administrative metadata with default construction" do
      adapter.construct_page
      asset = adapter.target
      expect(asset.depositor).to eq User.batch_user.user_key
      expect(asset.admin_set).to eq AdminSet.find(AdminSet::DEFAULT_ID)
      expect(asset.visibility).to eq 'open'
    end

    it "sets custom administrative metadata" do
      # test one exemplary/representative option:
      adapter = described_class.new(page_data, issue, visibility: 'open')
      adapter.construct_page
      expect(adapter.target.visibility).to eq 'open'
    end

    it "copies metadata to NewspaperPage" do
      adapter.construct_page
      page = adapter.target
      expect(page.title).to contain_exactly expected_title
      expect(page.width).to eq metadata.width
      expect(page.height).to eq metadata.height
      expect(page.page_number).to eq metadata.page_number
      expect(page.identifier).to contain_exactly metadata.identifier
    end
  end

  describe "reel/container linking" do
    # need publication, title, and reel to use for page data context:
    let(:publication) { create(:newspaper_title) }

    let(:issue) do
      issue = create(:newspaper_issue)
      publication.members << issue
      publication.save!
      issue
    end

    let(:issue_data) do
      IiifPrint::Ingest::NDNP::IssueIngest.new(issue2)
    end

    let(:page_data) do
      data = issue_data.to_a[0]
      # some NDNP samples missing TIFF, put dummy in place of missing, as needed
      data.files = data.files.map do |path|
        File.exist?(path) ? path : File.join(fixture_path, 'ocr_gray.tiff')
      end
      data
    end

    let(:adapter) { described_class.new(page_data, issue) }

    it "links page to reel" do
      # construct_page + link_reel ~= ingest without files import:
      adapter.construct_page
      adapter.link_reel
      page = adapter.target
      page.reload
      expect(page.container).not_to be_nil
      expect(page.container.ordered_members.to_a.map(&:id)).to include page.id
    end
  end

  describe "file import integration" do
    do_now_jobs = [IngestLocalFileJob, IngestJob, InheritPermissionsJob]

    let(:issue_data) do
      IiifPrint::Ingest::NDNP::IssueIngest.new(issue2)
    end

    let(:page_data_minus_tiff) { issue_data.to_a[0] }

    def check_fileset(page)
      fileset = page.members.find { |m| m.class == FileSet }
      # Reload fileset because jobs have modified:
      fileset.reload
      expect(fileset).not_to be_nil
      expect(fileset.original_file).not_to be_nil
      expect(fileset.original_file.mime_type).to eq 'image/tiff'
      expect(fileset.original_file.size).to be > 0
    end

    def expect_file_assignment_logging(adapter)
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('Assigned primary file to work') }
      ).once
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('Assigned derivative file to work') }
      ).exactly(3).times
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('Beginning file attachment') }
      ).once
    end

    def expect_page_import_logging(adapter)
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('Created NewspaperPage work') }
      ).once
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('Saved metadata to NewspaperPage work') }
      ).once
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('Linked NewspaperIssue') }
      ).once
    end

    it "attaches primary, derivative files", perform_enqueued: do_now_jobs do
      expect_page_import_logging(adapter)
      expect_file_assignment_logging(adapter)
      adapter.ingest
      page = adapter.target
      check_fileset(page)
      derivatives = IiifPrint::Data::WorkDerivatives.new(page)
      expect(derivatives.keys).to match_array ["jp2", "xml", "pdf"]
    end

    # support this use-case for evaluation purposes
    it "generates TIFF when missing from page", perform_enqueued: do_now_jobs do
      adapter = described_class.new(page_data_minus_tiff, issue)
      expect_page_import_logging(adapter)
      expect(adapter).to receive(:write_log).with(
        satisfy { |arg| arg.include?('Creating TIFF') },
        Logger::WARN
      ).exactly(1).times
      expect_file_assignment_logging(adapter)
      expect { adapter.ingest }.not_to raise_error
      check_fileset(adapter.target)
    end
  end
end
