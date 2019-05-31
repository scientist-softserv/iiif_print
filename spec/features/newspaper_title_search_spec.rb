require 'spec_helper'
require 'features_shared'

RSpec.describe 'newspaper title search' do
  include_context "fixtures_for_features"

  # @title1 comes from fixtures_for_features
  # rubocop:disable RSpec/InstanceVariable
  before do
    visit hyrax_newspaper_title_path(@title1.id)
    fill_in "q_issues", with: title_base_memo
  end
  # rubocop:enable RSpec/InstanceVariable

  it 'returns pages for this title' do
    click_button('issue-search')
    within "#search-results" do
      expect(page).to have_content "#{title1_issue1_title_memo}: Page 1"
      expect(page).to have_content "#{title1_issue1_title_memo}: Page 2"
      expect(page).not_to have_content "#{title2_issue1_title_memo}: Page 1"
    end
  end

  it 'returns only front pages if checked' do
    check 'f_first_page_bsi_'
    click_button('issue-search')
    within "#search-results" do
      expect(page).to have_content "#{title1_issue1_title_memo}: Page 1"
      expect(page).not_to have_content "#{title1_issue1_title_memo}: Page 2"
    end
  end
end
