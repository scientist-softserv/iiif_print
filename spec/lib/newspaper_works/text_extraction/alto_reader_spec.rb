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

  describe "reads alto" do
    it "loads ALTO source" do
      reader1 = described_class.new(minimal_path)
      reader2 = described_class.new(minimal)
      expect(reader1.source).to eq reader2.source
      expect(reader1.source.size).to eq 1383
      reader3 = described_class.new(ndnp_alto_path)
      expect(reader3.source.size).to eq 1_050_876
    end

    it "loads document stream" do
      reader = described_class.new(minimal_path)
      expect(reader.doc_stream).to be_kind_of Nokogiri::XML::SAX::Document
      expect(reader.doc_stream).to respond_to :text
      expect(reader.doc_stream).to respond_to :words
    end
  end

  describe "outputs text derivative formats" do
    it "outputs plain text" do
      # try simple flat text input
      reader = described_class.new(minimal)
      expect(reader.text).to eq "This is only a test."
      expect(reader.text).to eq reader.doc_stream.text
      # try more complex input
      reader = described_class.new(ndnp_alto_path)
      expect(reader.text.size).to eq 30_519
    end

    it "outputs flattened word-coordinate JSON" do
      reader = described_class.new(minimal)
      parsed = JSON.parse(reader.json)
      expect(parsed['words'].length).to be > 1
      reader = described_class.new(ndnp_alto_path)
      parsed = JSON.parse(reader.json)
      expect(parsed['words'].size).to eq 5_422
    end
  end
end
