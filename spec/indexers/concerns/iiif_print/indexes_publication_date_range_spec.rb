require 'spec_helper'

RSpec.describe IiifPrint::IndexesPublicationDateRange do
  let(:ntitle) { NewspaperTitle.new }
  let(:test_indexer) { NewspaperTitleIndexer.new(ntitle) }
  let(:solr_doc) { {} }
  let(:year) { '1975' }
  let(:year_month) { '1975-05' }

  describe '#index_pubdate_start' do
    describe 'with year only' do
      before { test_indexer.index_pubdate_start(year, solr_doc) }
      it 'formats YYYY start dates correctly' do
        expect(solr_doc['publication_date_start_dtsi']).to eq("#{year}-01-01T00:00:00Z")
      end
    end
    describe 'with year and month' do
      before { test_indexer.index_pubdate_start(year_month, solr_doc) }
      it 'formats YYYY-MM start dates correctly' do
        expect(solr_doc['publication_date_start_dtsi']).to eq("#{year_month}-01T00:00:00Z")
      end
    end
  end

  describe '#index_pubdate_end' do
    describe 'with year only' do
      before { test_indexer.index_pubdate_end(year, solr_doc) }
      it 'formats YYYY end dates correctly' do
        expect(solr_doc['publication_date_end_dtsi']).to eq("#{year}-12-31T23:59:59Z")
      end
    end
    describe 'with year and month' do
      before { test_indexer.index_pubdate_end(year_month, solr_doc) }
      it 'formats YYYY-MM end dates correctly' do
        expect(solr_doc['publication_date_end_dtsi']).to eq("#{year_month}-31T23:59:59Z")
      end
    end
  end
end
