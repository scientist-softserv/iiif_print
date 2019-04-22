require 'spec_helper'

RSpec.describe NewspaperWorksHelper do
  let(:query) { 'suffrage' }
  let(:document) { build(:newspaper_page_solr_document) }

  describe '#iiif_search_anchor' do
    it 'returns the correct string' do
      expect(helper.iiif_search_anchor(nil)).to eq nil
      expect(helper.iiif_search_anchor(query)).to eq("?h=#{query}")
    end
  end

  describe '#render_newspaper_thumbnail_tag' do
    it 'returns a thumbnail link with image and iiif search anchor' do
      result = helper.render_newspaper_thumbnail_tag(document, query)
      expect(result).to include "concern/newspaper_pages/#{document[:id]}#?h=#{query}"
    end
  end

  describe '#newspaper_thumbnail_tag' do
    it 'returns a thumbnail' do
      result = helper.newspaper_thumbnail_tag(document)
      expect(result).to include "img src=\"#{document[:thumbnail_path_ss]}"
    end
  end
end
