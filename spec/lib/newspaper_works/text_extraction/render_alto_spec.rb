require 'spec_helper'

RSpec.describe NewspaperWorks::TextExtraction::RenderAlto do
  let(:fixture_path) do
    File.join(
      NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  let(:altoxsd) do
    xsdpath = File.join(fixture_path, 'alto-2-0.xsd')
    Nokogiri::XML::Schema(File.read(xsdpath))
  end

  let(:page_prefix) { '<Page ID="ID1" PHYSICAL_IMG_NR="1"' }

  let(:words) do
    [
      { word: 'If',  x_start: 52, y_start: 13, x_end: 63, y_end: 27 },
      { word: 'you', x_start: 69, y_start: 17, x_end: 100, y_end: 31 },
      { word: 'are', x_start: 108, y_start: 17, x_end: 136, y_end: 27 },
      { word: 'a', x_start: 143, y_start: 17, x_end: 151, y_end: 27 },
      { word: 'friend,', x_start: 158, y_start: 13, x_end: 214, y_end: 29 },
      { word: 'you', x_start: 51, y_start: 39, x_end: 82, y_end: 53 },
      { word: 'speak', x_start: 90, y_start: 35, x_end: 140, y_end: 53 },
      { word: 'the', x_start: 146, y_start: 35, x_end: 174, y_end: 49 },
      { word: 'password,', x_start: 182, y_start: 35, x_end: 267, y_end: 53 },
      { word: 'and', x_start: 51, y_start: 57, x_end: 81, y_end: 71 },
      { word: 'the', x_start: 89, y_start: 57, x_end: 117, y_end: 71 },
      { word: 'doors', x_start: 124, y_start: 57, x_end: 172, y_end: 71 },
      { word: 'will', x_start: 180, y_start: 57, x_end: 208, y_end: 71 },
      { word: 'open.', x_start: 216, y_start: 61, x_end: 263, y_end: 75 }
    ]
  end

  describe "renders alto" do
    it "creates alto given width, height, words" do
      renderer = described_class.new(12_000, 9600)
      output = renderer.to_alto(words)
      expect(output.class).to be String
      expect(output).to include '<alto'
      expect(output).to include '<String'
      expect(output).to include page_prefix + ' HEIGHT="9600" WIDTH="12000"'
      expect(Nokogiri::XML(output).errors.empty?).to be true
    end

    it "makes alto 2.0 that validates" do
      renderer = described_class.new(12_000, 9600)
      output = renderer.to_alto(words)
      document = Nokogiri::XML(output)
      altoxsd.validate(document)
    end
  end
end
