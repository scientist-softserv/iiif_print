require 'spec_helper'
RSpec.describe NewspaperWorks::JP2DerivativeService do
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

  describe "Creates JP2 derivatives" do
    def source_image(name)
      File.join(fixture_path, name)
    end

    def expected_path(file_set)
      Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'jp2')
    end

    def get_res(path)
      lines = `gm identify -verbose #{path}`.lines
      lines.select { |line| line.strip.start_with?('Geometry') }[0].strip
    end

    def check_dpi_match(orig, dest)
      # check ppi, but skip pdf to avoid ghostscript warnings to stderr
      expect(get_res(orig)).to eq get_res(dest) unless orig.end_with?('pdf')
    end

    def makes_jp2(filename)
      expected = expected_path(valid_file_set)
      expect(File.exist?(expected)).to be false
      svc = described_class.new(valid_file_set)
      svc.create_derivatives(source_image(filename))
      expect(File.exist?(expected)).to be true
      desc = `gm identify #{expected}`
      expect(desc).to include 'JP2'
      check_dpi_match(source_image(filename), expected)
      svc.cleanup_derivatives
    end

    it "creates gray JP2 derivative from one-bit source" do
      makes_jp2('page1.tiff')
    end

    it "creates gray JP2 from grayscale source" do
      makes_jp2('lowres-gray-via-ndnp-sample.tiff')
    end

    it "creates color JP2 from color source" do
      makes_jp2('4.1.07.tiff')
    end

    it "creates JP2 from PDF source, robust to multi-page" do
      makes_jp2('sample-color-newsletter.pdf')
    end
  end
end
