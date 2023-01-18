require 'spec_helper'

RSpec.describe IiifPrint::IiifManifestPresenterBehavior do
  let(:attributes) do
    { "id" => "abc123",
      "title_tesim" => ['Page the first'],
      "description_tesim" => ['A book or something'],
      "creator_tesim" => ['Arthur McAuthor'] }
  end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:presenter) { Hyrax::IiifManifestPresenter.new(solr_document) }
  let(:test_request) { ActionDispatch::TestRequest.new({}) }

  describe '#search_service' do
    it 'returns the correct URL for the IIIF Search service' do
      expect(presenter.search_service).to include("#{solr_document.id}/iiif_search")
    end
  end
end
