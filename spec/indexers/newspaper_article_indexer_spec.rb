require 'spec_helper'

RSpec.describe NewspaperArticleIndexer do
  let(:article) do
    NewspaperArticle.new(
      id: 'foo1234',
      title: ['Whatever'],
      genre: %w[http://id.loc.gov/vocabulary/graphicMaterials/tgm000098 FOO]
    )
  end
  let(:indexer) { described_class.new(article) }

  describe '#generate_solr_document' do
    subject { indexer.generate_solr_document }

    it 'adds the correct fields to the Solr document' do
      expect(subject['genre_tesim']).not_to be_falsey
      expect(subject['genre_sim']).not_to be_falsey
    end

    it 'indexes genre terms with a URI correctly' do
      expect(subject['genre_tesim']).to include('Advertisement')
    end

    it 'indexes genre terms without a URI correctly' do
      expect(subject['genre_sim']).to include('FOO')
    end
  end
end
