require 'spec_helper'

describe NewspaperWorks::JP2ImageMetadata do
  let(:fixtures) { File.join(NewspaperWorks::GEM_PATH, 'spec/fixtures/files') }

  let(:gray_jp2) { File.join(fixtures, 'ocr_gray.jp2') }

  let(:color_jp2) { File.join(fixtures, '4.1.07.jp2') }

  describe "Extracts technical metadata from a JP2 file" do
    it "constructs with a path" do
      meta = described_class.new(gray_jp2)
      expect(meta.path).to eq gray_jp2
    end

    it "gets metadata for grayscale image" do
      meta = described_class.new(gray_jp2)
      result = meta.technical_metadata
      expect(result[:color]).to eq 'gray'
      expect(result[:width]).to eq 418
      expect(result[:height]).to eq 1046
      expect(result[:bits_per_component]).to eq 8
      expect(result[:num_components]).to eq 1
    end

    it "gets metadata for color image" do
      meta = described_class.new(color_jp2)
      result = meta.technical_metadata
      expect(result[:color]).to eq 'color'
      expect(result[:width]).to eq 256
      expect(result[:height]).to eq 256
      expect(result[:bits_per_component]).to eq 8
      # e.g. is 3, but would be four if sample image had an alpha channel
      expect(result[:num_components]).to eq 3
    end
  end
end
