require 'spec_helper'
RSpec.describe Hyrax::NewspaperPagesHelper do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:attributes) do
    { 'is_following_page_of_ssi' => 'foo', 'is_preceding_page_of_ssi' => 'bar' }
  end
  let(:presenter) { Hyrax::NewspaperPagePresenter.new(solr_document, nil) }

  describe '#previous_page_link' do
    it 'returns a link to the previous page' do
      expect(helper.previous_page_link(presenter)).to include('href="/concern/newspaper_pages/foo"')
    end
  end

  describe '#next_page_link' do
    it 'returns a link to the next page' do
      expect(helper.next_page_link(presenter)).to include('href="/concern/newspaper_pages/bar')
    end
  end
end
