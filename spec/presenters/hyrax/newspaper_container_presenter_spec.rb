require 'spec_helper'
require_relative '../newspaper_works/newspaper_core_presenter_spec'

RSpec.describe Hyrax::NewspaperContainerPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }

  let(:attributes) do
    { "extent" => ["1st"],
      "publication_date_start" => ["2017-08-25"],
      "publication_date_end" => ["2017-08-30"] }
  end

  it_behaves_like "a newspaper core presenter"

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:extent).to(:solr_document) }
  it { is_expected.to delegate_method(:publication_date_start).to(:solr_document) }
  it { is_expected.to delegate_method(:publication_date_end).to(:solr_document) }
end
