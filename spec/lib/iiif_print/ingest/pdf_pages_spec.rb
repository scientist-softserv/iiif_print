require 'spec_helper'
require 'mini_magick'

RSpec.describe IiifPrint::Ingest::PdfPages do
  let(:sample1) do
    base = Pathname.new(IiifPrint::GEM_PATH).join('spec/fixtures/files')
    base.join('sample-4page-issue.pdf').to_s
  end
  let(:sample2) do
    base = Pathname.new(IiifPrint::GEM_PATH).join('spec/fixtures/files')
    base.join('sample-color-newsletter.pdf').to_s
  end
  let(:sample3) do
    base = Pathname.new(IiifPrint::GEM_PATH).join('spec/fixtures/files')
    base.join('ndnp-sample1.pdf').to_s
  end
  let(:onebitpages) { described_class.new(sample1) }
  let(:colorpages) { described_class.new(sample2) }
  let(:graypages) { described_class.new(sample3) }

  describe "implementation details" do
    it "pdfinfo gets PdfImages, memoized" do
      pdfimages = onebitpages.pdfinfo
      expect(pdfimages).to be_a(IiifPrint::Ingest::PdfImages)
      pdfimages2 = onebitpages.pdfinfo
      # same object, method only fetches once:
      expect(pdfimages2).to equal pdfimages
    end

    it "gets correct Ghostscript TIFF output" do
      expect(onebitpages.gsdevice).to eq 'tiffg4'
      expect(colorpages.gsdevice).to eq 'tiff24nc'
    end

    it "gets text elements saved in PDF" do
      # should be little to nothing in scanned work, besides
      # output of Ghostscript banner:
      expect(onebitpages.gstext.length).to eq 0
      # the color sample is born-digital and thus has text in PDF;
      #   this checks for > 160 (non-trivial) text, though this text
      #   stream is at least 6k, if you strip out excess whitespace.
      expect(colorpages.gstext.length).to be > 160
    end

    it "gets reasonable ppi" do
      # 400 ppi native:
      expect(onebitpages.ppi).to eq 400
      # sourced from scan:
      expect(onebitpages.ppi).to eq onebitpages.pdfinfo.ppi
      # digital native content gets forced to 400 ppi...
      expect(colorpages.ppi).to eq 400
      # ...because the images in this sample are not reasonably
      #    representative, due to low PPI (not scans of whole pages):
      expect(colorpages.ppi).to be > colorpages.pdfinfo.ppi
    end
  end

  describe "splits PDF into pages with TIFF tmpfiles" do
    it "page filenames of TIFF files are ordered" do
      pages = colorpages.entries
      pages.each_with_index do |path, idx|
        n = idx + 1
        expect(path).to match(/page#{n}.tiff/)
      end
    end

    it "color sample splits into color TIFF per page" do
      pages = colorpages.entries
      pages.each do |path|
        image = MiniMagick::Image.open(path)
        expect(image.mime_type).to eq 'image/tiff'
        expect(image.colorspace).to start_with 'DirectClass sRGB'
      end
    end

    it "one bit sample splits into Group 4 TIFF per page" do
      pages = onebitpages.entries
      pages.each do |path|
        Open3.popen3("identify #{path}") do |_stdin, stdout, _stderr, _wait_thr|
          output = stdout.read
          expect(output).to include '1-bit'
          expect(output).to include 'Bilevel'
          expect(output).to include 'TIFF'
        end
      end
    end

    it "one bit sample is 7200x9600 scan, verify" do
      pages = onebitpages.entries
      pages.each do |path|
        image = MiniMagick::Image.open(path)
        expect(image.width).to eq 7200
        expect(image.height).to eq 9600
      end
    end

    it "processes Grayscale NDNP PDF correctly" do
      pages = graypages.entries
      expect(pages.length).to eq 1
      pages.each do |path|
        Open3.popen3("identify #{path}") do |_stdin, stdout, _stderr, _wait_thr|
          output = stdout.read
          expect(output).to include 'Grayscale'
          expect(output).to include '8-bit'
          expect(output).to include 'TIFF'
        end
      end
    end
  end
end
