require 'spec_helper'
require 'ndnp_shared'

RSpec.describe IiifPrint::Ingest::NDNP::IssueMetadata do
  include_context "ndnp fixture setup"

  describe "sample fixture 'batch_local'" do
    let(:issue) { described_class.new(issue1) }

    it "gets lccn" do
      expect(issue.lccn).to eq "sn85058233"
    end

    it "gets volume" do
      expect(issue.volume).to eq "56"
    end

    it "gets issue" do
      expect(issue.issue_number).to eq "27"
    end

    it "gets edition fields" do
      expect(issue.edition_name).to eq "Main Edition"
      expect(issue.edition_number).to eq "1"
    end

    it "gets publication date" do
      expect(issue.publication_date).to eq "1935-08-02"
    end

    it "gets publication title via //mets/@LABEL" do
      expect(issue.publication_title).to eq 'The Park Record (Park City, UT)'
    end

    it "gets held_by" do
      expect(issue.held_by).to eq "University of Utah; Salt Lake City, UT"
    end
  end

  describe "sample fixture 'batch_test_ver01" do
    let(:issue) { described_class.new(issue2) }
    let(:issue_ingest) do
      IiifPrint::Ingest::NDNP::IssueIngest.new(issue2)
    end

    it "gets lccn" do
      expect(issue.lccn).to eq "sn85025202"
    end

    it "gets volume" do
      expect(issue.volume).to eq "2"
    end

    it "gets issue" do
      expect(issue.issue_number).to eq "4"
    end

    it "gets edition fields" do
      expect(issue.edition_name).to be_nil
      expect(issue.edition_number).to eq "1"
    end

    it "gets publication date" do
      expect(issue.publication_date).to eq "1857-02-14"
    end

    it "gets publication title via label, when reel unavailable" do
      expect(issue.publication_title).to \
        eq 'Weekly Trinity journal (Weaverville, Calif.)'
    end

    # integration test for reel context publication title:
    it "gets publication title via label, from reel" do
      expect(issue_ingest.metadata.publication_title).to \
        eq 'Weekly Trinity journal (Weaverville, Calif.)'
      expect(issue_ingest.metadata.publication_title).to \
        eq issue_ingest.container.metadata.title
    end

    it "gets held_by" do
      expect(issue.held_by).to eq "University of Utah, Salt Lake City, UT"
    end
  end
end
