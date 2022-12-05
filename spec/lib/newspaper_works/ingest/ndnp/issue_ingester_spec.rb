require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::IssueIngester do
  include_context "ndnp fixture setup"

  # Source data:
  let(:issue_data) do
    NewspaperWorks::Ingest::NDNP::IssueIngest.new(issue1)
  end

  let(:metadata) { issue_data.metadata }

  # IssueIngester adapter does the work we are testing:
  let(:adapter) { described_class.new(issue_data) }

  describe "adapter and asset construction" do
    def expect_issue_import_logging(adapter)
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('Saved metadata to new NewspaperIssue') }
      ).once
    end

    # remove publication asset from repository for LCCN, when re-creating
    #   is desired test behavior
    def clear_publication(lccn)
      NewspaperTitle.where(lccn: lccn).delete_all
    end

    it "constructs adapter with issue source" do
      expect(adapter.issue).to be issue_data
      expect(adapter.path).to eq issue_data.path
      # initially nil target:
      expect(adapter.target).to be_nil
    end

    it "constructs adapter with hash options" do
      user = User.batch_user.user_key
      adapter = described_class.new(
        issue_data,
        depositor: user
      )
      expect(adapter.opts[:depositor]).to eq user
    end

    it "constructs NewspaperIssue with adapter" do
      # construct_issue is only the first part of ingest, create issue
      #   and find-or-link publication NewspaperTitle;
      #   this does not trigger creation of child pages.
      clear_publication(issue_data.metadata.lccn)
      expect_issue_import_logging(adapter)
      expect(adapter).to receive(:write_log).with(
        satisfy do |v|
          v.include?('Created NewspaperTitle work') ||
          v.include?('Found existing NewspaperTitle')
        end
      ).once
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('Linked NewspaperIssue') }
      ).once
      adapter.construct_issue
      issue = adapter.target
      expect(issue).to be_a NewspaperIssue
      expect(issue.id).not_to be_nil
      # check parent publication
      publication = issue.publication
      expect(publication.lccn).to eq issue_data.metadata.lccn
      expect(publication.title).to contain_exactly 'The Park Record'
    end

    it "creates new NewspaperTitle without place of publication" do
      # clear any existing publications from previous testing
      lccn = issue_data.metadata.lccn
      clear_publication(lccn)
      # construct with title, this time no username set for geonames:
      Qa::Authorities::Geonames.username = ''
      adapter.construct_issue
      expect(adapter.target.publication.place_of_publication).to be_empty
      Qa::Authorities::Geonames.username = 'newspaper_works'
    end
  end

  describe "metadata access/setting" do
    def normalized_pubtitle(issue_data)
      issue_data.metadata.publication_title.strip.split(/ \(/)[0]
    end

    def expected_title(issue_data)
      metadata = issue_data.metadata
      d = DateTime.iso8601(metadata.publication_date).strftime('%B %-d, %Y')
      "#{normalized_pubtitle(issue_data)}: #{d}"
    end

    it "copies metadata to NewspaperIssue" do
      adapter.construct_issue
      issue = adapter.target
      metadata = issue_data.metadata
      expect(issue.title).to contain_exactly expected_title(issue_data)
      expect(issue.lccn).to eq metadata.lccn
      expect(issue.volume).to eq metadata.volume
      expect(issue.publication_date).to eq metadata.publication_date
      expect(issue.issue_number).to eq metadata.issue_number
    end

    it "sets default administrative metadata with default construction" do
      adapter.construct_issue
      issue_asset = adapter.target
      expect(issue_asset.depositor).to eq User.batch_user.user_key
      expect(issue_asset.admin_set).to eq AdminSet.find(AdminSet::DEFAULT_ID)
      expect(issue_asset.visibility).to eq 'open'
    end

    it "sets custom administrative metadata for issue" do
      # test one exemplary/representative option:
      adapter = described_class.new(issue_data, visibility: 'open')
      adapter.construct_issue
      expect(adapter.target.visibility).to eq 'open'
    end

    it "sets custom administrative metadata for constructed publication" do
      # test one exemplary/representative option:
      adapter = described_class.new(issue_data, visibility: 'open')
      adapter.construct_issue
      publication_asset = adapter.target.publication
      expect(publication_asset).not_to be_nil
      expect(publication_asset.visibility).to eq 'open'
    end
  end

  describe "child page creation" do
    it "creates child pages on ingest of issue" do
      # calling ingest without invoking the ususal async jobs should
      #   create child pages without additional work of attaching files
      #   to them, which we don't need to test here (tested elsewhere).
      adapter.ingest
      adapter.target.pages.each do |page|
        expect(page.issue.id).to eq adapter.target.id
      end
    end
  end
end
