require 'spec_helper'

RSpec.describe IiifPrint::Ingest::ImageIngestIssues do
  include_context 'ingest test fixtures'

  let(:lccn) { 'sn93059126' }

  let(:publication) { IiifPrint::Ingest::PublicationInfo.new(lccn) }

  let(:pub_path) { File.join(tiff_fixtures, lccn) }

  let(:expected_paths) do
    entries = Dir.entries(pub_path).map { |p| File.join(pub_path, p) }
    entries.select { |p| File.directory?(p) && !File.basename(p).start_with?('.') }
  end

  let(:issues) { described_class.new(pub_path, publication) }

  describe " construction and metadata" do
    it "constructs with path and publication" do
      expect(issues.path).to eq pub_path
      expect(issues.publication).to be publication
      expect(issues.lccn).to eq lccn
      expect(issues.publication.lccn).to eq lccn
    end

    it "enumerates valid directories as IssueImages objects" do
      expect(issues.size).to eq 2
      enumerated = issues.values
      expect(enumerated.size).to eq issues.size
      sample = enumerated[0]
      expect(sample).to be_a IiifPrint::Ingest::IssueImages
      expect(File.dirname(sample.path)).to eq pub_path
    end

    it "presents hash-like mapping behavior" do
      # Keys are paths to directory containing issue images:
      expect(issues.keys).to match_array expected_paths
      # info and [] methods get IssueImages object for given path key:
      issue1 = issues[issues.keys[0]]
      issue2 = issues.info(issues.keys[1])
      expect(issue1).to be_a IiifPrint::Ingest::IssueImages
      expect(issue2).to be_a IiifPrint::Ingest::IssueImages
      expect(issue1.path).to eq issues.keys[0]
    end

    it "enumerates pairs like a hash" do
      issues.each_value do |v|
        expect(v).to be_a IiifPrint::Ingest::IssueImages
      end
      issues.each_key do |k|
        expect(expected_paths).to include k
      end
      issues.each do |path, info|
        expect(expected_paths).to include path
        expect(info).to be_a IiifPrint::Ingest::IssueImages
        expect(info.path).to eq path
      end
      expect(issues.to_a.size).to eq 2
    end
  end
end
