require 'spec_helper'

RSpec.describe NewspaperWorks::NewspapersSearchBuilder do
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  describe "#default_processor_chain" do
    subject { search_builder.default_processor_chain }
    it { is_expected.to include :facets_for_newspapers_search_form }
    it { is_expected.to include :newspaper_pages_only }
  end

  describe '#facets_for_newspapers_search_form' do
    subject { {} }
    before do
      allow(search_builder).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
      search_builder.facets_for_newspapers_search_form(subject)
    end

    it 'adds the blacklight advanced search config' do
      expect(subject["facet.field"]).to include 'genre_sim'
      expect(subject['rows']).to eq '0'
    end
  end

  describe '#newspaper_pages_only' do
    subject { {} }
    before { search_builder.newspaper_pages_only(subject) }
    it 'adds the page limit' do
      expect(subject[:fq]).to eq ["human_readable_type_sim:\"Newspaper Page\""]
    end
  end
end
