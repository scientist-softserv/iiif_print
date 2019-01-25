require 'spec_helper'
require_relative '../newspaper_works/newspaper_core_presenter_spec'

RSpec.describe Hyrax::NewspaperIssuePresenter do
  let(:ability) { double 'Ability' }
  let(:solr_document) { SolrDocument.new('id' => '123456') }
  let(:presenter) { described_class.new(SolrDocument.new('id' => 'abc123'), nil) }

  let(:attributes) do
    { "volume" => '888888',
      "edition" => '1st issue',
      "issue_number" => ['1st issue'],
      "extent" => ["1st"],
      "publication_date" => ["2017-08-25"] }
  end

  it_behaves_like "a newspaper core presenter"

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:volume).to(:solr_document) }
  it { is_expected.to delegate_method(:edition).to(:solr_document) }
  it { is_expected.to delegate_method(:issue_number).to(:solr_document) }
  it { is_expected.to delegate_method(:extent).to(:solr_document) }
  it { is_expected.to respond_to(:publication_date) }

  describe '#universal_viewer?' do
    let(:current_ability) { ability }
    let(:work_presenter) { Hyrax::NewspaperPagePresenter.new(solr_document, nil) }
    let(:work_presenters) { [work_presenter] }
    let(:iiif_enabled) { true }
    let(:work_model_name) { 'NewspaperPage' }

    before do
      allow(Hyrax.config).to receive(:iiif_image_server?).and_return(iiif_enabled)
      allow(presenter).to receive(:work_presenters).and_return(work_presenters)
      allow(presenter).to receive(:current_ability).and_return(current_ability)
      allow(work_presenter).to receive(:universal_viewer?).and_return(true)
      allow(work_presenter).to receive(:model_name).and_return(work_model_name)
      allow(current_ability).to receive(:can?).with(:read, solr_document.id).and_return(true)
    end

    subject { presenter.universal_viewer? }

    it { is_expected.to be true }

    context 'when iiif_image_server? config not set' do
      let(:iiif_enabled) { false }
      it { is_expected.to be false }
    end

    context 'when work_presenter is not a NewspaperPagePresenter' do
      let(:work_model_name) { 'foo' }
      it { is_expected.to be false }
    end
  end
end
