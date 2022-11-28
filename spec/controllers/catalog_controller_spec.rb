require 'spec_helper'

# specs to test that install generators have correctly modified CatalogController
RSpec.describe CatalogController do
  describe 'IiifPrint::InstallGenerator#add_index_fields_to_catalog_controller' do
    subject { described_class.blacklight_config.index_fields }

    it 'has IiifPrint index fields' do
      expect(subject['all_text_tsimv']).not_to be_falsey
    end
  end

  describe 'IiifPrint::BlacklightAdvancedSearchGenerator' do
    subject { described_class.blacklight_config }

    describe '#update_search_builder' do
      it 'sets the default SearchBuilder' do
        expect(subject.search_builder_class).to eq CustomSearchBuilder
      end
    end
  end
end
