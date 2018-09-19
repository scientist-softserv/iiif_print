require 'spec_helper'

RSpec.describe NewspaperWorks::IndexesPublicationDateRange do
  let(:ntitle) { NewspaperTitle.new }
  let(:test_indexer) { NewspaperTitleIndexer.new(ntitle) }

  describe '#index_pubdate_start' do
    let(:start) { test_indexer.index_pubdate_start('1975', {}) }
    let(:start_with_mm) { test_indexer.index_pubdate_start('1975-05', {}) }
    it 'formats start dates correctly' do
      expect(start).to eq('1975-01-01T00:00:00Z')
      expect(start_with_mm).to eq('1975-05-01T00:00:00Z')
    end
  end

  describe '#index_pubdate_end' do
    let(:end_date) { test_indexer.index_pubdate_end('1975', {}) }
    let(:end_date_with_mm) { test_indexer.index_pubdate_end('1975-05', {}) }
    it 'formats end dates correctly' do
      expect(end_date).to eq('1975-12-31T23:59:59Z')
      expect(end_date_with_mm).to eq('1975-05-31T23:59:59Z')
    end
  end
end
