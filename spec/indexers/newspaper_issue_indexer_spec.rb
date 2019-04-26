require 'spec_helper'

RSpec.describe NewspaperIssueIndexer do
  let(:issue) do
    NewspaperIssue.new(
      id: 'foo1234',
      title: ['Whatever']
    )
  end
  let(:indexer) { described_class.new(issue) }

  describe '#generate_solr_document' do
    subject { indexer.generate_solr_document }

    it 'adds the default edition field to the Solr document' do
      expect(subject['edition_tesim']).to eq('1')
    end
  end
end
