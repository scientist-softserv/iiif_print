require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::PageMetadata do
  include_context "ndnp fixture setup"

  describe "sample fixture 'batch_local'" do
    let(:page1) { described_class.new(issue1, nil, 'pageModsBib8') }
    let(:page2) { described_class.new(issue1, nil, 'pageModsBib6') }

    it "gets expected page number as String" do
      expect(page1.page_number).to eq "1"
      expect(page2.page_number).to eq "2"
    end

    it "gets expected sequence number as Integer" do
      expect(page1.page_sequence_number).to eq 1
      expect(page2.page_sequence_number).to eq 2
    end

    it "gets expected width from ALTO as Integer " do
      expect(page1.width).to eq 18_352
      expect(page2.width).to eq 18_200
    end

    it "gets expected height from ALTO as Integer " do
      expect(page1.height).to eq 28_632
      expect(page2.height).to eq 28_872
    end

    it "gets identifier from ALTO as primary file name" do
      expect(page1.identifier).to eq "/mnt/nash.iarchives.com/data01/jobq/root/projects/production/LeanProcessing/UofU/Park_Record/Park_Record_Set01/tpr_19350705-19380630/ocr/0657b.tif"
      expect(page2.identifier).to eq "/mnt/nash.iarchives.com/data01/jobq/root/projects/production/LeanProcessing/UofU/Park_Record/Park_Record_Set01/tpr_19350705-19380630/ocr/0656a.tif"
    end
  end

  describe "sample fixture 'batch_test_ver01" do
    let(:page) { described_class.new(issue2, nil, 'pageModsBib1') }

    it "fallback to sequence number on page without page number" do
      expect(page.page_number).to eq page.page_sequence_number.to_s
    end

    it "gets expected sequence number as Integer" do
      expect(page.page_sequence_number).to eq 1
    end

    it "gets expected width from ALTO as Integer " do
      expect(page.width).to eq 21_464
    end

    it "gets expected height from ALTO as Integer " do
      expect(page.height).to eq 30_268
    end

    it "gets identifier from ALTO as primary file name" do
      expect(page.identifier).to eq "././0225.tif"
    end
  end

  describe "sample fixture via Reel XML" do
    let(:page) { described_class.new(reel1, nil, 'targetModsBib1') }

    it "return nil page number when page and sequence missing" do
      expect(page.page_number).to eq nil
      expect(page.page_sequence_number).to eq nil
    end

    it "gets expected sequence number as Integer" do
      expect(page.page_sequence_number).to eq nil
    end

    it "gets expected width from ALTO as Integer " do
      expect(page.width).to eq 30_176
    end

    it "gets expected height from ALTO as Integer " do
      expect(page.height).to eq 29_152
    end

    it "gets identifier from ALTO as primary file name" do
      expect(page.identifier).to eq "./0001.tif"
    end
  end
end
