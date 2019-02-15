require 'spec_helper'

RSpec.describe CatalogController do
  describe 'NewspaperWorks::InstallGenerator#add_facets_to_catalog_controller' do
    subject { described_class.blacklight_config.facet_fields }

    it 'has NewspaperWorks facet fields' do
      expect(subject['place_of_publication_city_sim']).not_to be_falsey
      expect(subject['publication_title_ssi'].class).to eq(Blacklight::Configuration::FacetField)
      expect(subject['genre_sim'].label).to eq('Article type')
    end

    # rubocop:disable RSpec/ExampleLength
    it 'has definitions for non-displaying facet fields' do
      expect(subject['place_of_publication_label_sim']).not_to be_falsey
      expect(subject['issn_sim']).not_to be_falsey
      expect(subject['lccn_sim']).not_to be_falsey
      expect(subject['oclcnum_sim']).not_to be_falsey
      expect(subject['held_by_sim']).not_to be_falsey
      expect(subject['author_sim']).not_to be_falsey
      expect(subject['photographer_sim']).not_to be_falsey
      expect(subject['geographic_coverage_sim']).not_to be_falsey
      expect(subject['preceded_by_sim']).not_to be_falsey
      expect(subject['succeeded_by_sim']).not_to be_falsey
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
