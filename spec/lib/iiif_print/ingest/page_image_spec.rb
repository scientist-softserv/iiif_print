require 'spec_helper'

RSpec.describe IiifPrint::Ingest::PageImage do
  include_context 'ingest test fixtures'

  let(:lccn) { 'sn93059126' }

  let(:issue_path) { File.join(tiff_fixtures, lccn, '1853060401') }

  let(:publication) { IiifPrint::Ingest::PublicationInfo.new(lccn) }

  let(:issue) do
    IiifPrint::Ingest::IssueImages.new(issue_path, publication)
  end

  describe "page construction and metadata" do
    it "validates path to page image file" do
      garbage_path = '/path/to/nonexistent'
      expect { described_class.new(garbage_path, issue, 1) }.to raise_error ArgumentError
    end

    it "extracts page number, title from image filename" do
      path = issue.keys[0]
      page = described_class.new(path, issue, 1)
      expect(page.page_number).to eq "1"
      expect(page.title).to contain_exactly "The weekly journal: June 4, 1853: Page #{page.page_number}"
    end
  end
end
