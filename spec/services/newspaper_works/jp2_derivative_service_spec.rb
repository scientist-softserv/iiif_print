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

    def metadata_match_checker(source, target)
      target_meta = NewspaperWorks::ImageTool.new(target).metadata
      source_meta = NewspaperWorks::ImageTool.new(source).metadata
      expect(target_meta[:content_type]).to eq 'image/jp2'
      expect(target_meta[:width]).to eq source_meta[:width]
      expect(target_meta[:height]).to eq source_meta[:height]
    end

    def makes_jp2(filename)
      expected = expected_path(valid_file_set)
      expect(File.exist?(expected)).to be false
      svc = described_class.new(valid_file_set)
      source_path = source_image(filename)
      svc.create_derivatives(source_path)
      expect(File.exist?(expected)).to be true
      metadata_match_checker(source_path, expected)
      svc.cleanup_derivatives
    end

    it "creates gray JP2 derivative from one-bit source" do
      makes_jp2('ocr_mono.tiff')
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
