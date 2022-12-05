require 'spec_helper'
require 'ndnp_shared'

RSpec.describe IiifPrint::Ingest::NDNP::ContainerIngest do
  include_context "ndnp fixture setup"

  describe "sample fixture 'batch_test_ver01'" do
    let(:reel) { described_class.new(reel1) }

    it "gets metadata" do
      expect(reel.metadata).to be_a \
        IiifPrint::Ingest::NDNP::ContainerMetadata
      # uses same Nokogiri document context:
      expect(reel.metadata.doc).to be reel.doc
      # has identifier method equivalent to reel number
      expect(reel.identifier).to eq reel.metadata.reel_number
    end

    it "gets control image as PageIngest, by dmdid" do
      page = reel.page_by_dmdid('targetModsBib1')
      expect(page).to be_a IiifPrint::Ingest::NDNP::PageIngest
      expect(page.dmdid).to eq 'targetModsBib1'
    end

    it "shares xml document context with contained pages" do
      page = reel.page_by_dmdid('targetModsBib1')
      expect(page.doc).to be reel.doc
    end

    it "enumerates expected issues" do
      # enumerate by casting reel to Array
      issues = reel.to_a
      expect(issues.size).to eq 2
      expect(issues[0]).to be_a IiifPrint::Ingest::NDNP::IssueIngest
      expect(issues[0].path).to eq reel.issue_paths[0]
    end

    it "gets size, in issue count" do
      issues = reel.to_a
      expect(reel.size).to eq issues.size
      expect(reel.size).to eq reel.issue_paths.size
    end
  end
end
