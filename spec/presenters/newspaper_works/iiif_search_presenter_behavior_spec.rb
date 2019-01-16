require 'spec_helper'

RSpec.describe NewspaperWorks::IiifSearchPresenterBehavior do
  let(:solr_document) { SolrDocument.new('id' => 'abc123') }
  let(:presenter) { Hyrax::NewspaperPagePresenter.new(solr_document, nil) }
  let(:test_request) { ActionDispatch::TestRequest.new({}) }

  before { allow(presenter).to receive(:request).and_return(test_request) }

  describe '#search_service' do
    it 'returns the correct URL for the IIIF Search service' do
      expect(presenter.search_service).to include('abc123/iiif_search')
    end
  end
end
