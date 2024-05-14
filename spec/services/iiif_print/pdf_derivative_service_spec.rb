require 'spec_helper'
RSpec.describe IiifPrint::PDFDerivativeService do
  let(:valid_file_set) do
    file_set = FileSet.new
    file_set.save!(validate: false)
    file_set
  end
  let(:image_file) { double(image?: true) }
  let(:fixture_path) do
    File.join(
      IiifPrint::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  before do
    allow(valid_file_set).to receive(:original_file).and_return(image_file)
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
      metadata = IiifPrint::ImageTool.new(expected).metadata
      # get width of pdf in points (via imagemagick), should be 864x == 12in
      page_width = metadata[:width]
      expect(page_width).to eq 864
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
      metadata = IiifPrint::ImageTool.new(expected).metadata
      expect(metadata[:content_type]).to eq 'application/pdf'
      check_dpi(expected)
      svc.cleanup_derivatives
    end

    it "creates gray PDF derivative from one-bit source" do
      makes_pdf('ocr_mono.tiff')
    end

    it "creates gray PDF from grayscale source" do
      makes_pdf('lowres-gray-via-ndnp-sample.tiff')
    end

    it "creates color PDF from color source" do
      makes_pdf('4.1.07.tiff')
    end

    it "creates color PDF from color JP2 source" do
      makes_pdf('4.1.07.jp2')
    end
  end
end
