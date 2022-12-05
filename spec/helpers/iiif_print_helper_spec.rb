require 'spec_helper'

RSpec.describe IiifPrintHelper do
  let(:query_term) { 'suffrage' }
  let(:query_params_hash) { { q: query_term } }
  let(:document) { build(:newspaper_page_solr_document) }

  describe '#iiif_search_anchor' do
    it 'returns the correct string' do
      expect(helper.iiif_search_anchor({})).to eq nil
      expect(helper.iiif_search_anchor(query_params_hash)).to eq("?h=#{query_term}")
    end
  end

  describe '#search_query' do
    it 'returns the correct string' do
      expect(helper.search_query({})).to eq nil
      expect(helper.search_query(query_params_hash)).to eq(query_term)
    end
  end

  describe '#highlight_matches' do
    let(:hl_fl) { 'all_text_tsimv' }

    describe 'when highlighting is present in Solr response' do
      before do
        allow(document).to receive(:highlight_field).with(hl_fl).and_return(['foo <em>bar</em> baz'.html_safe])
      end
      it 'returns the matching terms when highlighting present' do
        expect(helper.highlight_matches(document, hl_fl, 'em')).to eq 'bar'
      end
    end

    describe 'when highlighting is not present' do
      before do
        allow(document).to receive(:highlight_field).with(hl_fl).and_return([])
      end
      it 'returns the matching terms when highlighting present' do
        expect(helper.highlight_matches(document, hl_fl, 'em')).to eq nil
      end
    end
  end
end
