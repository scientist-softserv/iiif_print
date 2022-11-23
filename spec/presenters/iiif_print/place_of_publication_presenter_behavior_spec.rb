require 'spec_helper'

RSpec.describe NewspaperWorks::PlaceOfPublicationPresenterBehavior do
  let(:pop) { 'Marysville, California, United States' }
  let(:request) { double(host: 'example.org') }
  let(:solr_document) do
    SolrDocument.new(id: 'abc123',
                     place_of_publication_label_tesim: [pop])
  end

  describe '#place_of_publication_label' do
    let(:presenter) { Hyrax::NewspaperPagePresenter.new(solr_document, nil, request) }
    it 'returns the value' do
      expect(presenter.place_of_publication_label).to eq [pop]
    end
  end
end
