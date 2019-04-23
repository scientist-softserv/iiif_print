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
    it "constructs adapter with issue source" do
      expect(adapter.issue).to be issue_data
      expect(adapter.path).to eq issue_data.path
      # default nil batch value when optional value omitted from construction:
      expect(adapter.batch).to be_nil
      # initially nil target:
      expect(adapter.target).to be_nil
    end

    it "constructs with optional batch reference" do
      batch = NewspaperWorks::Ingest::NDNP::BatchXMLIngest.new(batch1)
      adapter = described_class.new(issue_data, batch)
      expect(adapter.batch).to be batch
    end

    it "constructs NewspaperIssue with adapter" do
      # construct_issue is only the first part of ingest, create issue
      #   and find-or-link publication NewspaperTitle;
      #   this does not trigger creation of child pages.
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
      NewspaperTitle.where(lccn: lccn).delete_all
      # construct with title, this time no username set for geonames:
      Qa::Authorities::Geonames.username = ''
      adapter.construct_issue
      expect(adapter.target.publication.place_of_publication).to be_empty
      Qa::Authorities::Geonames.username = 'newspaper_works'
    end

    it "creates new NewspaperTitle with place of publication" do
      # clear any existing publications from previous testing
      lccn = issue_data.metadata.lccn
      NewspaperTitle.where(lccn: lccn).delete_all
      # construct with title, this time with username set for geonames:
      Qa::Authorities::Geonames.username = 'newspaper_works'
      adapter.construct_issue
      pop = adapter.target.publication.place_of_publication
      expect(pop).not_to be_empty
      expect(pop[0]).to start_with 'http://sws.geonames.org/'
    end
  end

  describe "metadata access/setting" do
    it "copies metadata to NewspaperIssue" do
      adapter.construct_issue
      issue = adapter.target
      metadata = issue_data.metadata
      title = "#{metadata.publication_title} (#{metadata.publication_date})"
      expect(issue.title).to contain_exactly title
      expect(issue.lccn).to eq metadata.lccn
      expect(issue.volume).to eq metadata.volume
      expect(issue.publication_date).to eq metadata.publication_date
      expect(issue.issue_number).to eq metadata.issue_number
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
