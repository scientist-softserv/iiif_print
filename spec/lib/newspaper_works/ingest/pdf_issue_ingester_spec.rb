require 'spec_helper'
require 'newspaper_works_fixtures'

RSpec.describe NewspaperWorks::Ingest::PDFIssueIngester do
  include_context "ingest test fixtures"

  describe "ingester construction and composition" do
    it "constructs ingester with expected metadata" do
      # given path to 'pdf_batch/sn93059126' directory containing PDFs:
      ingester = described_class.new(pdf_fixtures)
      # correctly parses LCCN from path:
      expect(ingester.lccn).to eq 'sn93059126'
      expect(ingester.path).to eq pdf_fixtures
    end

    it "constructs ingester with publication metadata" do
      ingester = described_class.new(pdf_fixtures)
      expect(ingester.publication).to be_a NewspaperWorks::Ingest::PublicationInfo
      expect(ingester.publication.lccn).to eq ingester.lccn
      expect(ingester.publication.title).to eq 'The weekly journal'
    end

    it "constructs ingester with explicit LCCN" do
      # path is for The weekly journal (Chicopee Mass), pass LCCN for other pub
      sltrib = 'sn83045396'
      ingester = described_class.new(pdf_fixtures, lccn: sltrib)
      expect(ingester.lccn).to eq sltrib
      expect(ingester.publication.lccn).to eq ingester.lccn
      expect(ingester.publication.title).to eq 'Salt Lake tribune'
    end

    it "constructs ingester enumerating PDF files" do
      ingester = described_class.new(pdf_fixtures)
      pdfs = Dir.entries(pdf_fixtures).select { |name| name.end_with?('.pdf') }
      paths = pdfs.map { |name| File.join(pdf_fixtures, name) }
      issues = ingester.issues
      expect(issues).to be_a NewspaperWorks::Ingest::PDFIssues
      expect(issues.size).to eq pdfs.size
      expect(issues.keys).to match_array paths
    end
  end

  describe "ingester behavior" do
    # Ensure LCCN has no initial publication NewspaperTitle asset:
    let(:lccn) do
      v = 'sn93059126'
      NewspaperTitle.where(lccn: v).delete_all
      v
    end

    let(:pdf_path) { File.join(pdf_fixtures, '1853060401.pdf') }

    let(:single_issue_dir) do
      Hyrax.config.whitelisted_ingest_dirs.push('/tmp')
      parent_dir = Dir.mktmpdir
      dir = File.join(parent_dir, lccn)
      FileUtils.mkdir(dir)
      FileUtils.cp(pdf_path, dir)
      dir
    end

    it "ingests PDFs" do
      ingester = described_class.new(single_issue_dir)
      ingester.ingest
      # Outcomes tested:
      # 1. NewspaperTitle fpr Publication created
      publication = NewspaperTitle.where(lccn: lccn).first
      expect(publication).not_to be_nil
      # 2. NewspaperIssue created and findable withing publication members
      issue = publication.members.to_a[0]
      expect(issue.publication_date).to eq "1853-06-04"
      expect(issue.title).to contain_exactly "The weekly journal: June 4, 1853"
      # Verify administrative metadata defaults:
      expect(issue.depositor).to eq User.batch_user.user_key
      expect(issue.admin_set).to eq AdminSet.find(AdminSet::DEFAULT_ID)
      expect(issue.visibility).to eq 'open'
      # Remove single-issue temporary directory
      FileUtils.rmtree(File.dirname(single_issue_dir))
    end
  end
end
