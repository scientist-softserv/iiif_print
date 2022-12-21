require 'spec_helper'
RSpec.describe CustomSearchBuilder do
  # specs for IiifPrint::HighlightSearchParams
  describe 'highlight_search_params' do
    let(:solr_parameters) { { q: 'abolition' } }
    subject { described_class.new(solr_parameters) }

    it 'is included in the default_processor_chain' do
      expect(described_class.default_processor_chain).to include(:highlight_search_params)
    end

    before { subject.highlight_search_params(solr_parameters) }
    it 'adds the highlight fields to solr_parameters' do
      expect(solr_parameters[:hl]).to be_truthy
      expect(solr_parameters[:'hl.fl']).to eq('all_text_tsimv')
    end
  end

  # specs for IiifPrint::ExcludeModels
  describe 'exclude_models' do
    let(:solr_parameters) { { all_fields: 'prohibition' } }
    subject { described_class.new(solr_parameters) }

    it 'is included in the default_processor_chain' do
      expect(described_class.default_processor_chain).to include(:exclude_models)
    end

    context 'with configured model name' do
      before do
        class ExcludedModel; end
        class AnotherExcludedModel; end
        IiifPrint.config.excluded_model_names = ["Excluded Model Name", "Another Excluded Model"]
        subject.exclude_models(solr_parameters)
      end

      it 'adds the facet fields to solr_parameters with configured key' do
        expect(solr_parameters[:fq]).to be_truthy
        expect(solr_parameters[:fq]).to(
          include("-has_model_ssim:\"Excluded Model Name\"", "-has_model_ssim:\"Another Excluded Model\"")
        )
      end
    end
  end
end
