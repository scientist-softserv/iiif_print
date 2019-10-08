require 'spec_helper'
RSpec.describe NewspaperWorks::TIFFDerivativeService do
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

  describe "Creates TIFF derivatives" do
    def source_image(name)
      File.join(fixture_path, name)
    end

    def expected_path(file_set)
      Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'tiff')
    end

    def get_res(path)
      tool = NewspaperWorks::ImageTool.new(path)
      "#{tool.metadata[:width]}x#{tool.metadata[:height]}"
    end

    def check_dpi_match(orig, dest)
      # check ppi, but skip pdf to avoid ghostscript warnings to stderr
      expect(get_res(orig)).to eq get_res(dest) unless orig.end_with?('pdf')
    end

    def makes_tiff(filename)
      path = source_image(filename)
      expected = expected_path(valid_file_set)
      expect(File.exist?(expected)).to be false
      svc = described_class.new(valid_file_set)
      svc.create_derivatives(path)
      expect(File.exist?(expected)).to be true
      mime = NewspaperWorks::ImageTool.new(expected).metadata[:content_type]
      expect(mime).to eq 'image/tiff'
      check_dpi_match(path, expected)
      svc.cleanup_derivatives
    end

    # for cases where primary file is TIFF already
    def avoids_duplicative_creation(filename)
      expected = expected_path(valid_file_set)
      expect(File.exist?(expected)).to be false
      svc = described_class.new(valid_file_set)
      svc.create_derivatives(source_image(filename))
      expect(File.exist?(expected)).not_to be true
    end

    it "Does not make TIFF derivatives when primary is TIFF" do
      avoids_duplicative_creation('ocr_mono.tiff')
      avoids_duplicative_creation('ocr_gray.tiff')
    end

    it "creates TIFF from PDF source, robust to multi-page" do
      makes_tiff('sample-color-newsletter.pdf')
    end
  end
end
