require 'spec_helper'
RSpec.describe CustomSearchBuilder do
  let(:solr_parameters) { { q: 'abolition' } }

  subject { described_class.new(solr_parameters) }

  describe 'fulltext_search_params' do
    it 'is included in the default_processor_chain' do
      expect(described_class.default_processor_chain).to include(:fulltext_search_params)
    end

    before { subject.fulltext_search_params(solr_parameters) }
    it 'adds the highlight fields to solr_parameters' do
      expect(solr_parameters[:hl]).to be_truthy
      expect(solr_parameters[:'hl.fl']).to eq('all_text_tsimv')
    end
  end
end
