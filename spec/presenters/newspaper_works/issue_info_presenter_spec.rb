require 'spec_helper'
RSpec.describe NewspaperWorks::IssueInfoPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:attributes) do
    {
      'issue_id_ssi' => 'foo',
      'issue_title_ssi' => 'bar',
      'issue_pubdate_dtsi' => 'baz',
      'issue_volume_ssi' => 'quux',
      'issue_edition_number_ssi' => '123',
      'issue_number_ssi' => '456'
    }
  end
  subject { Hyrax::NewspaperPagePresenter.new(solr_document, nil) }

  describe '#issue_id' do
    it 'returns the correct value' do
      expect(subject.issue_id).to eq 'foo'
    end
  end

  describe '#issue_title' do
    it 'returns the correct value' do
      expect(subject.issue_title).to eq 'bar'
    end
  end

  describe '#issue_pubdate' do
    it 'returns the correct value' do
      expect(subject.issue_pubdate).to eq 'baz'
    end
  end

  describe '#issue_volume' do
    it 'returns the correct value' do
      expect(subject.issue_volume).to eq 'quux'
    end
  end

  describe '#issue_edition' do
    it 'returns the correct value' do
      expect(subject.issue_edition).to eq '123'
    end
  end

  describe '#issue_number' do
    it 'returns the correct value' do
      expect(subject.issue_number).to eq '456'
    end
  end
end
