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
      "issue_edition_ssi" => '1',
      "issue_pubdate_dtsi" => "2017-08-25T00:00:00Z",
      "publication_unique_id_ssi" => "sn1234567" }
  end
  let(:presenter) { described_class.new(solr_document, ability, request) }

  it_behaves_like "a scanned media presenter"

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:height).to(:solr_document) }
  it { is_expected.to delegate_method(:width).to(:solr_document) }

  describe '#persistent_url' do
    subject { presenter.persistent_url }
    it { is_expected.to include '/newspapers/sn1234567/2017-08-25/ed-1/seq-1' }
  end
end
