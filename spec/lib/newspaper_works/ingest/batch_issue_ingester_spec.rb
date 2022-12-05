require 'spec_helper'
require 'newspaper_works_fixtures'

RSpec.describe NewspaperWorks::Ingest::BatchIssueIngester do
  include_context "ingest test fixtures"

  # lccn, paths for respective media:
  let(:pdf_lccn) { 'sn93059126' }
  let(:tiff_lccn) { 'sn93059126' }
  let(:jp2_lccn) { 'sn85058233' }
  let(:pdf_path) { File.join(pdf_fixtures, pdf_lccn) }
  let(:tiff_path) { File.join(tiff_fixtures, tiff_lccn) }
  let(:jp2_path) { File.join(jp2_fixtures, jp2_lccn) }

  describe "ingester construction and composition" do
    it "constructs ingester from PDF with expected metadata" do
      # given path to single batch
      ingester = described_class.new(pdf_path)
      # correctly parses LCCN from path:
      expect(ingester.lccn).to eq pdf_lccn
      expect(ingester.path).to eq pdf_path
    end

    it "constructs ingester from TIFF with expected metadata" do
      ingester = described_class.new(tiff_path)
      expect(ingester.lccn).to eq tiff_lccn
      expect(ingester.path).to eq tiff_path
    end

    it "constructs ingester from JP2 with expected metadata" do
      ingester = described_class.new(jp2_path)
      expect(ingester.lccn).to eq jp2_lccn
      expect(ingester.path).to eq jp2_path
    end

    it "constructs ingester with publication metadata" do
      ingester = described_class.new(pdf_path)
      expect(ingester.publication).to be_a NewspaperWorks::Ingest::PublicationInfo
      expect(ingester.publication.lccn).to eq ingester.lccn
      expect(ingester.publication.title).to eq 'The weekly journal'
    end

    it "constructs ingester with explicit LCCN" do
      # path is for The weekly journal (Chicopee Mass), pass LCCN for other pub
      sltrib = 'sn83045396'
      ingester = described_class.new(pdf_path, lccn: sltrib)
      expect(ingester.lccn).to eq sltrib
      expect(ingester.publication.lccn).to eq ingester.lccn
      expect(ingester.publication.title).to eq 'Salt Lake tribune'
    end

    it "constructs ingester enumerating PDF files" do
      ingester = described_class.new(pdf_path)
      pdfs = Dir.entries(pdf_path).select { |name| name.end_with?('.pdf') }
      paths = pdfs.map { |name| File.join(pdf_path, name) }
      issues = ingester.issues
      expect(issues).to be_a NewspaperWorks::Ingest::PDFIssues
      expect(issues.size).to eq pdfs.size
      expect(issues.keys).to match_array paths
    end

    it "constructs ingester enumerating issues of page images" do
      ingester = described_class.new(tiff_path)
      entries = Dir.entries(tiff_path)
                   .map { |name| File.join(tiff_path, name) }
                   .select { |v| !v.end_with?('.') && File.directory?(v) }
      issues = ingester.issues
      expect(issues).to be_a NewspaperWorks::Ingest::ImageIngestIssues
      expect(issues.size).to eq 2
      expect(issues.keys).to match_array entries
    end
  end

  describe "ingester behavior" do
    # Ensure LCCN has no initial publication NewspaperTitle asset:
    let(:pdf_lccn) do
      v = 'sn93059126'
      NewspaperTitle.where(lccn: v).delete_all
      v
    end

    let(:tiff_lccn) do
      v = 'sn93059126'
      NewspaperTitle.where(lccn: v).delete_all
      v
    end

    let(:jp2_lccn) do
      v = 'sn85058233'
      NewspaperTitle.where(lccn: v).delete_all
      v
    end

    let(:pdf_issue_path) { File.join(pdf_path, '1853060401.pdf') }
    let(:tiff_issue_path) { File.join(tiff_path, '1853060401') }
    let(:jp2_issue_path) { File.join(jp2_path, '1935080201') }

    def single_issue_dir(lccn, target_issue_path)
      Hyrax.config.whitelisted_ingest_dirs |= ['/tmp']
      parent_dir = Dir.mktmpdir
      dir = File.join(parent_dir, lccn)
      FileUtils.mkdir(dir)
      FileUtils.cp_r(target_issue_path, dir)
      dir
    end

    def job_enqueued?(job)
      jobs = ActiveJob::Base.queue_adapter.enqueued_jobs.map { |j| j[:job] }
      jobs.include?(job)
    end

    def expect_administrative_metadata(work)
      expect(work.depositor).to eq User.batch_user.user_key
      expect(work.admin_set).to eq AdminSet.find(AdminSet::DEFAULT_ID)
      expect(work.visibility).to eq 'open'
    end

    it "ingests PDFs" do
      expected_metadata = {
        title: "The weekly journal: June 4, 1853",
        publication_date: "1853-06-04"
      }
      issue_ingest(pdf_lccn, pdf_issue_path, 0, expected_metadata)
    end

    it "ingests JP2 page images (as TIFF) into an issue with child pages" do
      expected_metadata = {
        title: "The Park record: August 2, 1935",
        publication_date: "1935-08-02"
      }
      issue_ingest(jp2_lccn, jp2_issue_path, 2, expected_metadata)
    end
  end
end
