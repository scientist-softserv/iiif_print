require 'spec_helper'
require_relative '../iiif_print/newspaper_core_presenter_spec'

RSpec.describe Hyrax::NewspaperIssuePresenter do
  let(:ability) { double 'Ability' }
  let(:request) { double(host: 'example.org') }
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  let(:attributes) do
    { "id" => '123456',
      "volume_tesim" => ['8'],
      "edition_number_tesim" => ['1'],
      "issue_number_tesim" => ['1st issue'],
      "extent_tesim" => ["4 pages"],
      "publication_date_dtsi" => "2017-08-25T00:00:00Z",
      "publication_unique_id_ssi" => "sn1234567" }
  end

  it_behaves_like "a newspaper core presenter"

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:volume).to(:solr_document) }
  it { is_expected.to delegate_method(:edition_number).to(:solr_document) }
  it { is_expected.to delegate_method(:issue_number).to(:solr_document) }
  it { is_expected.to delegate_method(:extent).to(:solr_document) }
  it { is_expected.to respond_to(:publication_date) }

  describe '#iiif_viewer?' do
    let(:current_ability) { ability }
    let(:work_presenter) { Hyrax::NewspaperPagePresenter.new(solr_document, nil) }
    let(:work_presenters) { [work_presenter] }
    let(:iiif_enabled) { true }
    let(:work_model_name) { 'NewspaperPage' }

    before do
      allow(Hyrax.config).to receive(:iiif_image_server?).and_return(iiif_enabled)
      allow(presenter).to receive(:work_presenters).and_return(work_presenters)
      allow(presenter).to receive(:current_ability).and_return(current_ability)
      allow(work_presenter).to receive(:iiif_viewer?).and_return(true)
      allow(work_presenter).to receive(:model_name).and_return(work_model_name)
      allow(current_ability).to receive(:can?).with(:read, solr_document.id).and_return(true)
    end

    subject { presenter.iiif_viewer? }

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

  describe '#persistent_url' do
    subject { presenter.persistent_url }
    it { is_expected.to include '/newspapers/sn1234567/2017-08-25/ed-1' }
  end
end
