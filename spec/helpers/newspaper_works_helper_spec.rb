require 'spec_helper'

RSpec.describe NewspaperWorksHelper do
  let(:query_term) { 'suffrage' }
  let(:query_params_hash) { { q: query_term } }
  let(:document) { build(:newspaper_page_solr_document) }

  describe '#iiif_search_anchor' do
    it 'returns the correct string' do
      expect(helper.iiif_search_anchor({})).to eq nil
      expect(helper.iiif_search_anchor(query_params_hash)).to eq("?h=#{query_term}")
    end
  end

  describe '#render_newspaper_thumbnail_tag' do
    it 'returns a thumbnail link with image and iiif search anchor' do
      result = helper.render_newspaper_thumbnail_tag(document, query_params_hash)
      expect(result).to include "concern/newspaper_pages/#{document[:id]}#?h=#{query_term}"
    end
  end

  describe '#newspaper_thumbnail_tag' do
    it 'returns a thumbnail' do
      result = helper.newspaper_thumbnail_tag(document)
      expect(result).to include "img src=\"#{document[:thumbnail_path_ss]}"
    end
  end
end
