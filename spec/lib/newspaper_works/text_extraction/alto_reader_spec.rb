require 'json'
require 'spec_helper'

RSpec.describe NewspaperWorks::TextExtraction::AltoReader do
  let(:fixture_path) do
    File.join(
      NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  let(:minimal_path) { File.join(fixture_path, 'minimal-alto.xml') }
  let(:ndnp_alto_path) { File.join(fixture_path, 'ndnp-alto-sample.xml') }
  let(:minimal) { File.read(minimal_path) }

  let(:reader_minimal) { described_class.new(minimal) }
  let(:reader_minimal_path) { described_class.new(minimal_path) }
  let(:reader_ndnp) { described_class.new(ndnp_alto_path) }

  describe "reads alto" do
    it "loads ALTO source" do
      expect(reader_minimal_path.source).to eq reader_minimal.source
      expect(reader_minimal_path.source.size).to eq 1383
      expect(reader_ndnp.source.size).to eq 1_050_876
    end

    it "loads document stream" do
      expect(reader_minimal_path.doc_stream).to be_kind_of Nokogiri::XML::SAX::Document
      expect(reader_minimal_path.doc_stream).to respond_to :text
      expect(reader_minimal_path.doc_stream).to respond_to :words
    end
  end

  describe "outputs text derivative formats" do
    it "outputs plain text" do
      # try simple flat text input
      expect(reader_minimal.text).to eq "This is only a test."
      expect(reader_minimal.text).to eq reader_minimal.doc_stream.text
      # try more complex input
      expect(reader_ndnp.text.size).to eq 30_519
    end

    it "passes args to WordCoordsBuilder and receives output" do
      parsed = JSON.parse(reader_minimal.json)
      expect(parsed['coords'].length).to be > 1
      parsed = JSON.parse(reader_ndnp.json)
      expect(parsed['coords'].size).to eq 2_125
    end
  end
end
