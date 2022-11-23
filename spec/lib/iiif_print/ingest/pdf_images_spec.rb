require 'spec_helper'

RSpec.describe NewspaperWorks::Ingest::PdfImages do
  let(:path) do
    base = Pathname.new(NewspaperWorks::GEM_PATH).join('spec/fixtures/files')
    base.join('sample-4page-issue.pdf').to_s
  end
  let(:pdfimages) { described_class.new(path) }

  describe "get image sizing from PDF" do
    it "gets width" do
      expect(pdfimages.width).to be 7200
    end

    it "gets height" do
      expect(pdfimages.height).to be 9600
    end

    it "gets ppi" do
      expect(pdfimages.ppi).to be 400
    end
  end

  describe "get image info from PDF" do
    it "gets color info" do
      color, channels, bits = pdfimages.color
      expect(color).to eq 'gray'
      expect(channels).to be 1
      expect(bits).to be 1
    end
  end
end
