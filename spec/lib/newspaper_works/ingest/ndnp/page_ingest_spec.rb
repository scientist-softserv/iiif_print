require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::PageIngest do
  include_context "ndnp fixture setup"

  def file_type?(path, ext)
    path.split('/')[-1].split('.')[-1].casecmp(ext).zero?
  end

  def includes_file_type(files, ext)
    files.any? { |path| file_type?(path, ext) }
  end

  def check_expected_files(page, extensions)
    files = page.files
    expect(files.size).to eq extensions.size
    files.each do |filepath|
      # each path is normalized to absolute path
      expect(filepath.start_with?('/')).to be true
    end
    extensions.each do |ext|
      expect(includes_file_type(files, ext)).to be true
    end
  end

  describe "sample fixture 'batch_local'" do
    let(:page) { described_class.new(issue1, 'pageModsBib8') }

    it "gets metadata" do
      expect(page.metadata).to be_a NewspaperWorks::Ingest::NDNP::PageMetadata
      # uses same Nokogiri document context:
      expect(page.metadata.doc).to be page.doc
    end

    it "gets expected files" do
      check_expected_files(page, ['tif', 'jp2', 'pdf', 'xml'])
    end

    it "gets nil container for page without reel XML" do
      reel = page.container
      expect(reel).to be_nil
    end
  end

  describe "sample fixture 'batch_test_ver01'" do
    let(:page) { described_class.new(issue2, 'pageModsBib1') }

    it "gets metadata" do
      expect(page.metadata).to be_a NewspaperWorks::Ingest::NDNP::PageMetadata
      # uses same Nokogiri document context:
      expect(page.metadata.doc).to be page.doc
    end

    it "gets expected files" do
      check_expected_files(page, ['tif', 'jp2', 'pdf', 'xml'])
    end

    it "gets a ContainerIngest for reel providing page" do
      reel = page.container
      expect(reel).to be_a NewspaperWorks::Ingest::NDNP::ContainerIngest
      expect(reel.path).to end_with '_1.xml'
    end
  end

  describe "sample fixture reel xml (for control images)" do
    let(:page) { described_class.new(reel1, 'targetModsBib1') }

    it "gets metadata" do
      expect(page.metadata).to be_a NewspaperWorks::Ingest::NDNP::PageMetadata
      # uses same Nokogiri document context:
      expect(page.metadata.doc).to be page.doc
    end

    it "gets expected files" do
      check_expected_files(page, ['tif', 'jp2', 'pdf', 'xml'])
    end
  end
end
