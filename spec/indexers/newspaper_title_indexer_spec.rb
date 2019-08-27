require 'spec_helper'

RSpec.describe NewspaperTitleIndexer do
  let(:ntitle) do
    NewspaperTitle.new(
      id: 'foo1234',
      title: ['Whatever'],
      publication_date_start: '1975',
      publication_date_end: '1995'
    )
  end
  let(:indexer) { described_class.new(ntitle) }

  describe '#generate_solr_document' do
    subject { indexer.generate_solr_document }

    it 'indexes date ranges correctly' do
      expect(subject['publication_date_start_dtsi']).to eq('1975-01-01T00:00:00Z')
      expect(subject['publication_date_end_dtsi']).to eq('1995-12-31T23:59:59Z')
    end
  end
end
