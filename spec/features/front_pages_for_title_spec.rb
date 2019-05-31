require 'spec_helper'
require 'features_shared'

RSpec.describe 'front_pages_for_title' do
  include_context "fixtures_for_features"

  # @title1 comes from fixtures_for_features
  # rubocop:disable RSpec/InstanceVariable
  before do
    visit hyrax_newspaper_title_path(@title1.id)
    click_link('front_pages_search')
  end
  # rubocop:enable RSpec/InstanceVariable

  it 'returns the front pages' do
    within "#search-results" do
      expect(page).to have_content "#{title1_issue1_title_memo}: Page 1"
      expect(page).not_to have_content "#{title1_issue1_title_memo}: Page 2"
    end
  end
end
