require 'spec_helper'

RSpec.describe IiifPrint::Ingest::LCPublicationInfo do
  let(:lccn1) { 'sn83021453' }
  let(:lccn2) { 'sn83045396' }
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

  describe "error handling" do
    it "handles unknown LCCN (empty mods)" do
      meta = described_class.new(bad_lccn)
      expect(meta.empty?).to be true
    end
  end
end
