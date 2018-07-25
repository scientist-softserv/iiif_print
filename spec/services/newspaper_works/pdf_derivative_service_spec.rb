require 'spec_helper'
RSpec.describe NewspaperWorks::PDFDerivativeService do
  let(:valid_file_set) do
    file_set = FileSet.new
    file_set.save!(validate: false)
    file_set
  end

  let(:fixture_path) do
    File.join(
      NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  describe "Creates PDF derivatives" do
    def source_image(name)
      File.join(fixture_path, name)
    end

    def expected_path(file_set)
      Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'pdf')
    end

    # given output file name, check DPI is 150
    def check_dpi(expected)
      desc = `gm identify #{expected}`
      # get total width of pdf in points from identify, should be 864x == 12in
      page_width = 864
      expect(desc).to include "#{page_width}x"
      # get total width of image in pixels from pdfimages -list, ==> 1800
      image_width = 1800
      im_list = `pdfimages -list #{expected}`
      expect(im_list.lines[-1].split(' ')[3]).to eq image_width.to_s
      # this combination of page pt width, image px width ==> 150ppi
      expect(image_width / (page_width / 72.0)).to eq 150.0
    end

    def makes_pdf(filename)
      expected = expected_path(valid_file_set)
      expect(File.exist?(expected)).to be false
      svc = described_class.new(valid_file_set)
      svc.create_derivatives(source_image(filename))
      expect(File.exist?(expected)).to be true
      desc = `gm identify #{expected}`
      expect(desc).to include 'PDF'
      check_dpi(expected)
      svc.cleanup_derivatives
    end

    it "creates gray PDF derivative from one-bit source" do
      makes_pdf('page1.tiff')
    end

    it "creates gray PDF from grayscale source" do
      makes_pdf('lowres-gray-via-ndnp-sample.tiff')
    end

    it "creates color PDF from color source" do
      makes_pdf('4.1.07.tiff')
    end
  end
end
