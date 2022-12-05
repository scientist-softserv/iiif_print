require 'spec_helper'
require 'ndnp_shared'

RSpec.describe IiifPrint::Ingest::NDNP::IssueIngest do
  include_context "ndnp fixture setup"

  describe "sample fixture 'batch_local'" do
    let(:issue) { described_class.new(issue1) }

    it "gets metadata" do
      expect(issue.metadata).to be_a IiifPrint::Ingest::NDNP::IssueMetadata
      # uses same Nokogiri document context:
      expect(issue.metadata.doc).to be issue.doc
      # has identifier method equivalent to lccn
      expect(issue.identifier).to eq issue.metadata.lccn
    end

    it "gets nil container for issue without reel XML" do
      reel = issue.container
      expect(reel).to be_nil
    end

    it "gets page by dmdid" do
      page = issue.page_by_dmdid('pageModsBib8')
      expect(page).to be_a IiifPrint::Ingest::NDNP::PageIngest
      expect(page.metadata.page_sequence_number).to eq 1
      expect(page.dmdid).to eq 'pageModsBib8'
    end

    it "gets page by sequence number" do
      page = issue.page_by_sequence_number(1)
      expect(page.metadata.page_sequence_number).to eq 1
      expect(page.dmdid).to eq 'pageModsBib8'
      page = issue.page_by_sequence_number(2)
      expect(page.metadata.page_sequence_number).to eq 2
      expect(page.dmdid).to eq 'pageModsBib6'
    end

    it "shares xml document context with contained pages" do
      page = issue.page_by_sequence_number(1)
      expect(page.doc).to be issue.doc
    end

    it "enumerates expected pages" do
      # enumerate by casting issue to Array
      pages = issue.to_a
      expect(pages.size).to eq 2
      expect(pages[0]).to be_a IiifPrint::Ingest::NDNP::PageIngest
      expect(pages[0].metadata.page_sequence_number).to eq 1
    end

    it "gets size, in page count" do
      pages = issue.to_a
      expect(issue.size).to eq pages.size
      expect(issue.size).to eq issue.dmdids.size
    end
  end

  describe "sample fixture 'batch_test_ver01'" do
    let(:issue) { described_class.new(issue2) }

    it "gets a ContainerIngest for reel providing issue" do
      reel = issue.container
      expect(reel).to be_a IiifPrint::Ingest::NDNP::ContainerIngest
      expect(reel.path).to end_with '_1.xml'
    end

    it "gets metadata" do
      expect(issue.metadata).to be_a IiifPrint::Ingest::NDNP::IssueMetadata
      # uses same Nokogiri document context:
      expect(issue.metadata.doc).to be issue.doc
      # has identifier method equivalent to lccn
      expect(issue.identifier).to eq issue.metadata.lccn
    end

    it "gets page by dmdid" do
      page = issue.page_by_dmdid('pageModsBib1')
      expect(page).to be_a IiifPrint::Ingest::NDNP::PageIngest
      expect(page.metadata.page_sequence_number).to eq 1
      expect(page.dmdid).to eq 'pageModsBib1'
    end

    it "shares xml document context with contained pages" do
      page = issue.page_by_sequence_number(1)
      expect(page.doc).to be issue.doc
    end

    it "gets page by sequence number" do
      page = issue.page_by_sequence_number(1)
      expect(page.metadata.page_sequence_number).to eq 1
      expect(page.dmdid).to eq 'pageModsBib1'
    end

    it "enumerates expected pages" do
      # enumerate by casting issue to Array
      pages = issue.to_a
      expect(pages.size).to eq 1
      expect(pages[0]).to be_a IiifPrint::Ingest::NDNP::PageIngest
      expect(pages[0].metadata.page_sequence_number).to eq 1
    end

    it "gets size, in page count" do
      pages = issue.to_a
      expect(issue.size).to eq pages.size
      expect(issue.size).to eq issue.dmdids.size
    end
  end
end
