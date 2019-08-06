require 'spec_helper'

RSpec.describe NewspaperWorks::Ingest::ChronAmPublicationInfo do
  let(:lccn1) { 'sn94051019' }
  let(:lccn2) { 'sn84038814' }
  let(:bad_lccn) { 'sn99999999' }

  describe "gets metadata" do
    it "gets simple metadata" do
      meta = described_class.new(lccn1)
      expect(meta.title).to eq 'Marysville daily news'
      expect(meta.issn).to be_nil
      expect(meta.oclcnum).to eq 'ocm30043558'
      expect(meta.place_name).to eq 'Marysville, Calif.'
      expect(meta.place_of_publication).to eq 'http://sws.geonames.org/5370984/'
    end

    it "gets related item metadata" do
      meta1 = described_class.new(lccn1)
      meta2 = described_class.new(lccn2)
      # lccn2 succeeds lccn1, favors lccn.loc.gov URL as authoritative:
      expect(meta1.succeeded_by).to eq "https://lccn.loc.gov/#{lccn2}"
      # lccn1 precedes lccn2, favors chronam URL as authoritative, since
      #   catalog.loc.gov and lccn.loc.gov do not have records for this LCCN:
      expect(meta2.preceded_by).to eq "https://chroniclingamerica.loc.gov/lccn/sn94051019"
    end
  end

  describe "error handling" do
    it "handles unknown LCCN (404)" do
      meta = described_class.new(bad_lccn)
      expect(meta.empty?).to be true
    end
  end
end
