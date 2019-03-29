require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::ContainerMetadata do
  include_context "ndnp fixture setup"

  describe "sample fixture 'batch_test_ver01'" do
    let(:meta) { described_class.new(reel1) }

    it "gets reel_number" do
      expect(meta.reel_number).to eq "00279557177"
    end

    it "gets held_by" do
      expect(meta.held_by).to eq "University of Utah, Salt Lake City, UT"
    end

    it "gets genre" do
      expect(meta.genre).to eq 'microfilm'
    end

    it "gets title" do
      expect(meta.title).to eq 'Daily national Democrat (Marysville, Calif.)'
    end

    it "gets start date" do
      expect(meta.publication_date_start).to eq '1858-08-13'
    end

    it "gets end date" do
      expect(meta.publication_date_end).to eq '1858-12-31'
    end
  end
end
