require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::IssueMetadata do
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
      expect(issue.issue).to eq "27"
    end

    it "gets edition" do
      expect(issue.edition).to eq "Main Edition"
    end

    it "gets publication date" do
      expect(issue.publication_date).to eq "1935-08-02"
    end

    it "gets held_by" do
      expect(issue.held_by).to eq "University of Utah; Salt Lake City, UT"
    end
  end

  describe "sample fixture 'batch_test_ver01" do
    let(:issue) { described_class.new(issue2) }

    it "gets lccn" do
      expect(issue.lccn).to eq "sn85025202"
    end

    it "gets volume" do
      expect(issue.volume).to eq "2"
    end

    it "gets issue" do
      expect(issue.issue).to eq "4"
    end

    it "gets edition" do
      expect(issue.edition).to eq "1"
    end

    it "gets publication date" do
      expect(issue.publication_date).to eq "1857-02-14"
    end

    it "gets held_by" do
      expect(issue.held_by).to eq "University of Utah, Salt Lake City, UT"
    end
  end
end
