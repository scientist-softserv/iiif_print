require 'spec_helper'

RSpec.describe IiifPrint::PersistentUrlPresenterBehavior do
  let(:request) { double(host: 'example.org') }
  let(:solr_document) { SolrDocument.new(id: 'abc123', lccn_tesim: ['sn1234567']) }

  describe '#persistent_url' do
    let(:presenter) { Hyrax::NewspaperArticlePresenter.new(solr_document, nil, request) }
    it 'returns nil' do
      expect(presenter.persistent_url).to eq nil
    end
  end

  describe '#persistent_url_attribute' do
    let(:presenter) { Hyrax::NewspaperTitlePresenter.new(solr_document, nil, request) }
    let(:purl_attribute) { presenter.persistent_url_attribute }
    subject { Nokogiri::HTML(purl_attribute) }
    it 'returns the HTML for the metadata display' do
      expect(subject.css('dd')).not_to be_blank
      expect(subject.css('li.attribute')).not_to be_blank
      expect(subject.css('a').attribute('href').value).to include '/newspapers/sn1234567'
    end
  end
end
