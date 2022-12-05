require 'spec_helper'

RSpec.describe IiifPrint::NewspaperCoreIndexer do
  let(:geonames_uri) { 'http://sws.geonames.org/4950065/' }
  let(:pop) { Hyrax::ControlledVocabularies::Location.new(geonames_uri) }
  let(:article) do
    NewspaperArticle.new(
      id: 'foo1234',
      title: ['Whatever'],
      place_of_publication: [pop]
    )
  end
  let(:indexer) { described_class.new(article) }

  describe '#generate_solr_document' do
    subject { indexer.generate_solr_document }
    it 'processes place_of_publication field' do
      expect(subject['place_of_publication_tesim']).to include(geonames_uri)
      expect(subject['place_of_publication_city_sim']).to include('Salem')
      expect(subject['place_of_publication_state_sim']).to include('Massachusetts')
    end
  end
end
