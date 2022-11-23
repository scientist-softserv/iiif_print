require 'json'
require 'nokogiri'
require 'spec_helper'

RSpec.describe IiifPrint::TextExtraction::HOCRReader do
  let(:fixture_path) do
    File.join(
      IiifPrint::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  let(:minimal_path) { File.join(fixture_path, 'ocr_mono_text_hocr.html') }
  let(:minimal) { File.read(minimal_path) }

  let(:reader_minimal) { described_class.new(minimal) }
  let(:reader_minimal_path) { described_class.new(minimal_path) }

  describe "reads hOCR" do
    it "loads hOCR either from path or source text" do
      expect(reader_minimal_path.source).to eq reader_minimal.source
      # size here is in Unicode characters, not bytes:
      expect(reader_minimal_path.source.size).to eq 16_590
    end

    it "loads document stream" do
      expect(reader_minimal_path.doc_stream).to be_kind_of Nokogiri::XML::SAX::Document
      expect(reader_minimal_path.doc_stream).to respond_to :text
      expect(reader_minimal_path.doc_stream).to respond_to :words
    end
  end

  describe "outputs text derivative formats" do
    it "outputs plain text" do
      plain_text = reader_minimal.text
      expect(plain_text.slice(0, 40)).to eq "_A  FEARFUL  ADVENTURE.\n‘The  Missouri. "
      expect(reader_minimal.text).to eq reader_minimal.doc_stream.text
      expect(reader_minimal.text.size).to eq 831
    end

    it "passes args to WordCoordsBuilder and receives output" do
      parsed = JSON.parse(reader_minimal.json)
      expect(parsed['coords'].length).to be > 1
    end
  end
end
