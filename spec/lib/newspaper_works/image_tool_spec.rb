require 'spec_helper'
require 'tmpdir'

describe NewspaperWorks::ImageTool do
  let(:fixtures) { File.join(NewspaperWorks::GEM_PATH, 'spec/fixtures/files') }

  # Image fixtures to test identification, metadata extraction for:
  let(:gray_jp2) { File.join(fixtures, 'ocr_gray.jp2') }
  let(:color_jp2) { File.join(fixtures, '4.1.07.jp2') }
  let(:gray_tiff) { File.join(fixtures, 'ocr_gray.tiff') }
  let(:mono_tiff) { File.join(fixtures, 'ocr_mono.tiff') }
  let(:color_tiff) { File.join(fixtures, '4.1.07.tiff') }
  let(:pdf) { File.join(fixtures, 'minimal-1-page.pdf') }

  describe "Extracts metadata with JP2 backend" do
    it "constructs with a path" do
      identify = described_class.new(gray_jp2)
      expect(identify.path).to eq gray_jp2
    end

    it "gets metadata for grayscale JP2 image" do
      result = described_class.new(gray_jp2).metadata
      expect(result[:color]).to eq 'gray'
      expect(result[:width]).to eq 418
      expect(result[:height]).to eq 1046
      expect(result[:bits_per_component]).to eq 8
      expect(result[:num_components]).to eq 1
    end

    it "gets metadata for color JP2 image" do
      result = described_class.new(color_jp2).metadata
      expect(result[:color]).to eq 'color'
      expect(result[:width]).to eq 256
      expect(result[:height]).to eq 256
      expect(result[:bits_per_component]).to eq 8
      # e.g. is 3, but would be four if sample image had an alpha channel
      expect(result[:num_components]).to eq 3
    end
  end

  describe "Extracts metadata for non-JP2 images with imagemagick" do
    it "gets metadata for gray TIFF image" do
      result = described_class.new(gray_tiff).metadata
      expect(result[:color]).to eq 'gray'
      expect(result[:width]).to eq 418
      expect(result[:height]).to eq 1046
      expect(result[:bits_per_component]).to eq 8
      expect(result[:num_components]).to eq 1
    end

    it "gets metadata for monochrome TIFF image" do
      result = described_class.new(mono_tiff).metadata
      expect(result[:color]).to eq 'monochrome'
      expect(result[:width]).to eq 1261
      expect(result[:height]).to eq 1744
      expect(result[:bits_per_component]).to eq 1
      expect(result[:num_components]).to eq 1
    end

    it "gets metadata for color TIFF image" do
      result = described_class.new(color_tiff).metadata
      expect(result[:color]).to eq 'color'
      expect(result[:width]).to eq 256
      expect(result[:height]).to eq 256
      expect(result[:bits_per_component]).to eq 8
      # e.g. is 3, but would be four if sample image had an alpha channel
      expect(result[:num_components]).to eq 3
    end

    it "detects mime type of pdf" do
      result = described_class.new(pdf).metadata
      expect(result[:content_type]).to eq 'application/pdf'
    end
  end

  describe "converts images" do
    it "makes a monochrome TIFF from JP2" do
      tool = described_class.new(gray_jp2)
      dest = File.join(Dir.mktmpdir, 'mono.tif')
      tool.convert(dest, true)
      expect(File.exist?(dest)).to be true
      expect(described_class.new(dest).metadata[:color]).to eq 'monochrome'
    end

    it "makes a gray TIFF from JP2" do
      tool = described_class.new(gray_jp2)
      dest = File.join(Dir.mktmpdir, 'gray.tif')
      tool.convert(dest, false)
      expect(File.exist?(dest)).to be true
      expect(described_class.new(dest).metadata[:color]).to eq 'gray'
    end

    it "makes a monochrome TIFF from grayscale TIFF" do
      tool = described_class.new(gray_tiff)
      dest = File.join(Dir.mktmpdir, 'mono.tif')
      tool.convert(dest, true)
      expect(File.exist?(dest)).to be true
      expect(described_class.new(dest).metadata[:color]).to eq 'monochrome'
    end

    # Not yet supported to use this tool to make JP2, for now the only
    #   component in NewspaperWorks doing that is
    #   NewspaperWorks::JP2DerivativeService
    it "raises error on JP2 destination" do
      expect { described_class.new(gray_tiff).convert('out.jp2') }.to \
        raise_error(RuntimeError)
    end
  end
end
