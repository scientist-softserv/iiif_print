require 'spec_helper'
require_relative '../newspaper_works/scanned_media_presenter_spec'

RSpec.describe Hyrax::NewspaperPagePresenter do
  let(:ability) { double 'Ability' }
  let(:request) { double(host: 'example.org') }
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:attributes) do
    { "id" => "page1",
      "height" => "1000px",
      "width" => "800px",
      "issue_id_ssi" => "issue1",
      "issue_edition_number_ssi" => '1',
      "publication_date_dtsim" => ["2017-08-25T00:00:00Z"],
      "publication_unique_id_ssi" => "sn1234567",
      'is_following_page_of_ssi' => 'foo',
      'is_preceding_page_of_ssi' => 'bar',
      'container_id_ssi' => 'baz',
      'container_title_ssi' => 'quux',
      'article_ids_ssim' => ['123456'],
      'article_titles_ssim' => ['Test Title'] }
  end

  let(:presenter) { described_class.new(solr_document, ability, request) }

  it_behaves_like "a scanned media presenter"

  subject { described_class.new(solr_document, double) }

  it { is_expected.to delegate_method(:height).to(:solr_document) }
  it { is_expected.to delegate_method(:width).to(:solr_document) }

  describe '#persistent_url' do
    subject { presenter.persistent_url }
    it { is_expected.to include '/newspapers/sn1234567/2017-08-25/ed-1/seq-1' }
  end

  describe 'object relationship methods' do
    describe '#previous_page_id' do
      it 'returns the correct value' do
        expect(subject.previous_page_id).to eq 'foo'
      end
    end

    describe '#next_page_id' do
      it 'returns the correct value' do
        expect(subject.next_page_id).to eq 'bar'
      end
    end

    describe '#container_id' do
      it 'returns the correct value' do
        expect(subject.container_id).to eq 'baz'
      end
    end

    describe '#container_title' do
      it 'returns the correct value' do
        expect(subject.container_title).to eq 'quux'
      end
    end

    describe '#article_ids' do
      it 'returns the correct value' do
        expect(subject.article_ids).to eq ['123456']
      end
    end

    describe '#article_titles' do
      it 'returns the correct value' do
        expect(subject.article_titles).to eq ['Test Title']
      end
    end
  end
end
