require 'spec_helper'
require_relative '../newspaper_works/scanned_media_presenter_spec'

RSpec.describe Hyrax::NewspaperPagePresenter do
  let(:solr_document) { SolrDocument.new(attributes) }

  let(:attributes) do
    { "height" => "1000px",
      "width" => "800px" }
  end

  it_behaves_like "a scanned media presenter"

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:height).to(:solr_document) }
  it { is_expected.to delegate_method(:width).to(:solr_document) }
end
