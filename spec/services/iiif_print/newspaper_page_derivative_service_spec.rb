require 'spec_helper'

RSpec.describe IiifPrint::NewspaperPageDerivativeService do
  let(:valid_file_set) do
    fs = FileSet.new
    work = NewspaperPage.new
    work.title = ['This is a page!']
    work.members.push(fs)
    fs.save!(validate: false)
    work.save!(validate: false)
    fs
  end

  let(:unconsidered_file_set) do
    fs = FileSet.new
    work = NewspaperIssue.new
    work.title = ['Hello Hello']
    work.members.push(fs)
    work.save!(validate: false)
    fs.save!(validate: false)
    fs
  end

  let(:fixture_path) do
    File.join(
      IiifPrint::GEM_PATH, 'spec', 'fixtures', 'files'
    )
  end

  describe "core path/extension functionality" do
    class MyDerivativeService < described_class
      TARGET_EXT = 'jpg'.freeze
    end

    it "allows derivative service subclass to define file extension" do
      svc = MyDerivativeService.new(valid_file_set)
      expect(svc.class.target_ext).to eq 'jpg'
    end

    it "considers file_sets belonging to page work type" do
      svc = MyDerivativeService.new(valid_file_set)
      expect(svc.valid?).to eq true
    end

    it "ignores file_sets belonging to non-page work type" do
      svc = MyDerivativeService.new(unconsidered_file_set)
      expect(svc.valid?).to eq false
    end

    it "gets derivative path factory for file extension" do
      svc = MyDerivativeService.new(valid_file_set)
      svc.load_destpath
      expected = Hyrax::DerivativePath.derivative_path_for_reference(
        valid_file_set,
        'jpg'
      )
      expected_pairtree = File.join(expected.split('/')[0..-2])
      expect(Pathname.new(expected_pairtree)).to be_directory
      # cleanup:
      FileUtils.rm_rf(expected_pairtree)
    end

    it "successfully removes on cleanup_derivatives" do
      svc = MyDerivativeService.new(valid_file_set)
      # load destpath just makes directories
      svc.load_destpath
      expected = Hyrax::DerivativePath.derivative_path_for_reference(
        valid_file_set,
        'jpg'
      )
      expected_pairtree = File.join(expected.split('/')[0..-2])
      expect(Pathname.new(expected_pairtree)).to be_directory
      # simulate, simply touch a file with correct extension in
      #   the derivative path made above; makes a zero-byte '.jpg' file
      `touch #{expected}`
      expect(File.exist?(expected)).to be true
      svc.cleanup_derivatives
      # no more derivative file for this extension:
      expect(File.exist?(expected)).to be false
      # however, we still have a directory hanging around, this is normal,
      #   becauase any derivative service is blind to other derivatives
      #   for the same fileset, beside the one extension each manages:
      expect(Pathname.new(expected_pairtree)).to be_directory
      # cleanup after test:
      FileUtils.rm_rf(expected_pairtree)
    end
  end

  describe "source identification" do
    def service_for_file(name)
      # construct a new service for each test, as there are memoized things
      #   that make sharing problematic
      svc = described_class.new(valid_file_set)
      svc.instance_variable_set(:@source_path, File.join(fixture_path, name))
      svc
    end

    it "identifies a source file using ImageMagick" do
      service = service_for_file('4.1.07.tiff')
      expect(service.identify[:content_type]).to eq 'image/tiff'
      expect(service.identify[:bits_per_component]).to eq 8
    end

    it "identifies jp2 source" do
      # test/verify jp2 source is identified, which relies on JP2 backend
      service = service_for_file('4.1.07.jp2')
      expect(service.identify[:content_type]).to eq 'image/jp2'
      expect(service.identify[:bits_per_component]).to eq 8
    end

    it "identifies color and gray sources" do
      expect(service_for_file('4.1.07.tiff').use_color?).to be true
      expect(service_for_file('ocr_gray.tiff').use_color?).to be false
    end

    it "identifies a one-bit source" do
      # 1-bit group4 monochrome TIFF:
      expect(service_for_file('ocr_mono.tiff').one_bit?).to be true
      # 8-bit gray TIFF:
      expect(
        service_for_file('lowres-gray-via-ndnp-sample.tiff').one_bit?
      ).to be false
      # color TIFF:
      expect(service_for_file('4.1.07.tiff').one_bit?).to be false
    end
  end
end
