require 'nokogiri'
require 'spec_helper'

RSpec.describe NewspaperWorks::TextExtraction::PageOCR do
  let(:fixture_path) do
    File.join(
      NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  let(:altoxsd) do
    xsdpath = File.join(fixture_path, 'alto-2-0.xsd')
    Nokogiri::XML::Schema(File.read(xsdpath))
  end

  # sample "snippet" images for OCR testing:
  let(:example_gray_tiff) { File.join(fixture_path, 'ocr_gray.tiff') }
  let(:example_mono_tiff) { File.join(fixture_path, 'ocr_mono.tiff') }
  let(:example_color_tiff) { File.join(fixture_path, 'ocr_color.tiff') }
  let(:example_gray_jp2) { File.join(fixture_path, 'ocr_gray.jp2') }

  describe "performs OCR" do
    def match_ocr_expectations(words)
      expect(words).to be_an(Array)
      expect(words).not_to be_empty
      expect(words[0]).to be_a(Hash)
      [:word, :x_start, :y_start, :x_end, :y_end].each do |key|
        expect(words[0].keys).to include key
      end
    end

    it "gets words and coordinates from grayscale source" do
      ocr = described_class.new(example_gray_tiff)
      match_ocr_expectations(ocr.words)
    end

    it "gets words and coordinates from one-bit source" do
      ocr = described_class.new(example_mono_tiff)
      match_ocr_expectations(ocr.words)
    end

    it "gets words and coordinates from color source" do
      ocr = described_class.new(example_color_tiff)
      match_ocr_expectations(ocr.words)
    end

    it "gets words and coordinates from jp2 source" do
      ocr = described_class.new(example_gray_jp2)
      match_ocr_expectations(ocr.words)
    end
  end

  describe "turns image into ALTO" do
    it "takes grayscale tiff, outputs valid ALTO, geometry" do
      ocr = described_class.new(example_gray_tiff)
      alto = ocr.alto
      document = Nokogiri::XML(alto)
      errors = altoxsd.validate(document)
      expect(errors.length).to eq 0
      expect(document.at_css('PrintSpace')['WIDTH']).to eq "418"
      expect(document.at_css('PrintSpace')['HEIGHT']).to eq "1046"
    end
  end

  describe "plain text" do
    it "makes plain text available for image" do
      ocr = described_class.new(example_gray_tiff)
      plain = ocr.plain
      expect(plain.class).to be String
      expect(plain.length).to be > 0
    end
  end
end
