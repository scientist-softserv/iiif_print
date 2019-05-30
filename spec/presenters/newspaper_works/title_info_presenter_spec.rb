require 'spec_helper'
RSpec.describe NewspaperWorks::TitleInfoPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:attributes) do
    {
      'publication_id_ssi' => 'foo',
      'publication_title_ssi' => 'bar'
    }
  end
  subject { Hyrax::NewspaperPagePresenter.new(solr_document, nil) }

  describe '#publication_id' do
    it 'returns the correct value' do
      expect(subject.publication_id).to eq 'foo'
    end
  end

  describe '#publication_title' do
    it 'returns the correct value' do
      expect(subject.publication_title).to eq 'bar'
    end
  end
end
