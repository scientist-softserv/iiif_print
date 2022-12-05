require 'spec_helper'

RSpec.describe IiifPrint::Ingest::PDFIssue do
  include_context 'ingest test fixtures'

  let(:lccn) { 'sn93059126' }

  let(:pdf_path) { File.join(pdf_fixtures, lccn, '1853060401.pdf') }

  let(:publication) { IiifPrint::Ingest::PublicationInfo.new(lccn) }

  describe "issue construction and metadata" do
    it "constructs with path and publication" do
      issue = described_class.new(pdf_path, publication)
      expect(issue.path).to eq pdf_path
      expect(issue.filename).to eq File.basename(pdf_path)
      expect(issue.publication).to be publication
      expect(issue.lccn).to eq lccn
      expect(issue.publication.lccn).to eq lccn
    end

    it "extracts date, edition, title from filename" do
      issue = described_class.new(pdf_path, publication)
      expect(issue.publication_date).to eq '1853-06-04'
      expect(issue.edition_number).to eq 1
      expect(issue.title).to contain_exactly 'The weekly journal: June 4, 1853'
    end
  end
end
