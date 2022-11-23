require 'spec_helper'

RSpec.describe NewspaperWorks::Ingest::PDFIssues do
  include_context 'ingest test fixtures'

  let(:lccn) { 'sn93059126' }

  let(:publication) { NewspaperWorks::Ingest::PublicationInfo.new(lccn) }

  let(:pub_path) { File.join(pdf_fixtures, lccn) }

  describe " construction and metadata" do
    it "constructs with path and publication" do
      issues = described_class.new(pub_path, publication)
      expect(issues.path).to eq pub_path
      expect(issues.publication).to be publication
      expect(issues.lccn).to eq lccn
      expect(issues.publication.lccn).to eq lccn
    end

    it "enumerates valid pdfs as PDFIssue objects" do
      issues = described_class.new(pub_path, publication)
      expect(issues.size).to eq 5
      enumerated = issues.values
      expect(enumerated.size).to eq issues.size
      sample = enumerated[0]
      expect(sample).to be_a NewspaperWorks::Ingest::PDFIssue
      expect(File.dirname(sample.path)).to eq pub_path
    end

    it "presents hash-like mapping behavior" do
      issues = described_class.new(pub_path, publication)
      expected_paths = Dir.entries(pub_path).map { |p| File.join(pub_path, p) }
      expected_paths = expected_paths.select { |p| p.end_with?('.pdf') }
      # Keys are paths to file:
      expect(issues.keys).to match_array expected_paths
      # info and [] methods get PDFIssue for given path key:
      issue1 = issues[issues.keys[0]]
      issue2 = issues.info(issues.keys[1])
      expect(issue1).to be_a NewspaperWorks::Ingest::PDFIssue
      expect(issue2).to be_a NewspaperWorks::Ingest::PDFIssue
      expect(issue1.path).to eq issues.keys[0]
    end

    it "enumerates pairs like a hash" do
      issues = described_class.new(pub_path, publication)
      expected_paths = Dir.entries(pub_path).map { |p| File.join(pub_path, p) }
      issues.each_value do |v|
        expect(v).to be_a NewspaperWorks::Ingest::PDFIssue
      end
      issues.each_key do |k|
        expect(expected_paths).to include k
      end
      issues.each do |path, info|
        expect(expected_paths).to include path
        expect(info).to be_a NewspaperWorks::Ingest::PDFIssue
        expect(info.path).to eq path
      end
      expect(issues.to_a.size).to eq 5
    end
  end
end
