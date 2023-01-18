require 'spec_helper'

RSpec.describe IiifPrint::Configuration do
  describe "#metadata_fields" do
    subject { config.metadata_fields }
    let(:config) { described_class.new }

    it { is_expected.to be_a Hash }
    it "allows for an override" do
      original = config.metadata_fields
      config.metadata_fields = { title: {} }
      expect(config.metadata_fields).not_to eq original
    end
  end

  describe "#sort_iiif_manifest_canvases_by" do
    subject { config.sort_iiif_manifest_canvases_by }
    let(:config) { described_class.new }

    it { is_expected.to be_a Symbol }
    it "allows for an override" do
      original = config.sort_iiif_manifest_canvases_by
      config.sort_iiif_manifest_canvases_by = :title
      expect(config.metadata_fields).not_to eq original
    end
  end
end
