require 'spec_helper'
require_relative '../newspaper_works/newspaper_core_presenter_spec'

RSpec.describe Hyrax::NewspaperTitlePresenter do
  let(:solr_document) { SolrDocument.new(attributes) }

  let(:attributes) do
    { "edition" => "1st",
      "frequency" => ["often"],
      "preceded_by" => ["Something"],
      "succeeded_by" => ["Something Else"] }
  end

  it_behaves_like "a newspaper core presenter"

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:edition).to(:solr_document) }
  it { is_expected.to delegate_method(:frequency).to(:solr_document) }
  it { is_expected.to delegate_method(:preceded_by).to(:solr_document) }
  it { is_expected.to delegate_method(:succeeded_by).to(:solr_document) }
end
