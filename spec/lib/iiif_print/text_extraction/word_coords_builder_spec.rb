require 'spec_helper'

RSpec.describe NewspaperWorks::TextExtraction::WordCoordsBuilder do
  let(:words) do
    [
      { word: "foo", coordinates: [1, 2, 3, 4] },
      { word: "bar", coordinates: [5, 6, 7, 8] },
      { word: "baz", coordinates: [9, 10, 11, 12] },
      { word: "foo", coordinates: [13, 14, 15, 16] }
    ]
  end
  let(:image_width) { 1_234 }
  let(:image_height) { 5_678 }

  describe '.json_coordinates_for' do
    let(:wcb_to_json) { JSON.parse(described_class.json_coordinates_for(words: words, width: image_width, height: image_height)) }
    it 'has the correct structure' do
      expect(wcb_to_json['height']).to eq image_height
      expect(wcb_to_json['width']).to eq image_width
      expect(wcb_to_json['coords'].length).to eq 3
      expect(wcb_to_json['coords']['foo']).not_to be_falsey
    end

    it 'combines coordinates for the same word' do
      expect(wcb_to_json['coords']['foo']).to eq [[1, 2, 3, 4], [13, 14, 15, 16]]
    end
  end

  describe '#to_json' do
    let(:wcb_to_json) { JSON.parse(wcb.to_json) }
    let(:wcb) { described_class.new(words, image_width, image_height) }

    it 'has the correct structure' do
      expect(wcb_to_json['height']).to eq image_height
      expect(wcb_to_json['width']).to eq image_width
      expect(wcb_to_json['coords'].length).to eq 3
      expect(wcb_to_json['coords']['foo']).not_to be_falsey
    end

    it 'combines coordinates for the same word' do
      expect(wcb_to_json['coords']['foo']).to eq [[1, 2, 3, 4], [13, 14, 15, 16]]
    end
  end
end
