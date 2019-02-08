require 'spec_helper'
require_relative '../newspaper_works/newspaper_core_presenter_spec'
require_relative '../newspaper_works/scanned_media_presenter_spec'

RSpec.describe Hyrax::NewspaperArticlePresenter do
  let(:attributes) do
    { "author" => '888888',
      "photographer" => ['foo', 'bar'],
      "genre" => ["Editorials"],
      "volume" => ["volume 1"],
      "edition" => ["1st"],
      "issue_number" => ['1'],
      "geographic_coverage" => ["wide"],
      "extent" => ["vast"],
      "publication_date" => ["2017-08-25"] }
  end

  it_behaves_like "a newspaper core presenter"
  it_behaves_like "a scanned media presenter"

  subject { described_class.new(double, double) }

  it { is_expected.to delegate_method(:author).to(:solr_document) }
  it { is_expected.to delegate_method(:photographer).to(:solr_document) }
  it { is_expected.to delegate_method(:genre).to(:solr_document) }
  it { is_expected.to delegate_method(:volume).to(:solr_document) }
  it { is_expected.to delegate_method(:edition).to(:solr_document) }
  it { is_expected.to delegate_method(:issue_number).to(:solr_document) }
  it { is_expected.to delegate_method(:geographic_coverage).to(:solr_document) }
  it { is_expected.to delegate_method(:extent).to(:solr_document) }
  it { is_expected.to respond_to(:publication_date) }
end
