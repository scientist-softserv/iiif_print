require 'spec_helper'

RSpec.describe IiifPrint::IiifManifestPresenterBehavior do
  let(:attributes) do
    { "id" => "abc123",
      "title_tesim" => ['Page the first'],
      "page_number_tesim" => ['20'],
      "section_tesim" => ['B'] }
  end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:presenter) { Hyrax::IiifManifestPresenter.new(solr_document) }
  let(:test_request) { ActionDispatch::TestRequest.new({}) }

  describe '#search_service' do
    it 'returns the correct URL for the IIIF Search service' do
      expect(presenter.search_service).to include("#{solr_document.id}/iiif_search")
    end
  end

  describe '#manifest_metadata' do
    subject { presenter.manifest_metadata }

    xit { is_expected.not_to be_falsey }

    xit 'returns the correct metadata array for the manifest' do
      expect(subject.map { |v| v["label"] }).to include('Page number')
      expect(subject.map { |v| v["value"] }).to include(['B'])
    end
  end
end
