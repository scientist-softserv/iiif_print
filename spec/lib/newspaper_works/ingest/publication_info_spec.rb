require 'spec_helper'

RSpec.describe NewspaperWorks::Ingest::PublicationInfo do
  # prefers lccn.loc.gov:
  let(:lccn1) { 'sn83021453' }
  let(:lccn2) { 'sn83045396' }
  # prefers ChronAm:
  let(:lccn3) { 'sn94051019' }
  let(:bad_lccn) { 'sn99999999' }

  describe "gets metadata" do
    it "gets simple metadata" do
      meta = described_class.new(lccn1)
      expect(meta.title).to eq 'Salt Lake daily tribune'
      expect(meta.issn).to be_nil
      expect(meta.oclcnum).to eq 'ocm10170377'
      expect(meta.place_name).to eq 'Salt Lake City, Utah'
      expect(meta.place_of_publication).to eq 'http://sws.geonames.org/5780993/'
    end

    it "gets related item metadata" do
      meta1 = described_class.new(lccn1)
      meta2 = described_class.new(lccn2)
      # lccn2 succeeds lccn1, favors lccn.loc.gov URL as authoritative:
      expect(meta1.succeeded_by).to eq "https://lccn.loc.gov/#{lccn2}"
      # lccn1 precedes lccn2, favors lccn.loc.gov URL as authoritative:
      expect(meta2.preceded_by).to eq "https://lccn.loc.gov/sn83021453"
    end
  end

  describe "backing authority choice" do
    it "picks default authority of lccn.loc.gov" do
      meta = described_class.new(lccn1)
      expect(meta.implementation).to be_a NewspaperWorks::Ingest::LCPublicationInfo
    end

    it "picks chronam implementation when lccn.loc.gov empty for LCCN" do
      meta = described_class.new(lccn3)
      expect(meta.implementation).to be_a NewspaperWorks::Ingest::ChronAmPublicationInfo
    end

    it "responds to known metadata" do
      meta = described_class.new(lccn3)
      expect(meta).to respond_to(:lccn)
      expect(meta).to respond_to(:issn)
      expect(meta).to respond_to(:title)
      expect(meta).to respond_to(:oclcnum)
      expect(meta).to respond_to(:place_name)
      expect(meta).to respond_to(:place_of_publication)
      expect(meta).to respond_to(:preceded_by)
      expect(meta).to respond_to(:succeeded_by)
    end
  end

  describe "error handling" do
    it "handles unknown LCCN (empty mods)" do
      meta = described_class.new(bad_lccn)
      expect(meta.empty?).to be true
    end
  end
end
