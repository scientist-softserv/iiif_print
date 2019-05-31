require 'spec_helper'
require 'features_shared'

RSpec.describe 'newspapers_search' do
  include_context "fixtures_for_features"

  # title_base_memo comes from fixtures_for_features
  before do
    visit newspaper_works.newspapers_search_path
    fill_in "all_fields", with: title_base_memo
  end

  it 'returns results for keyword search' do
    click_button('search-submit-newspapers')
    within "#search-results" do
      expect(page).to have_content "#{title1_issue1_title_memo}: Page 1"
      expect(page).to have_content "#{title1_issue1_title_memo}: Page 2"
      expect(page).to have_content "#{title2_issue1_title_memo}: Page 1"
    end
  end

  it 'returns correct results for keyword search with front page' do
    check 'f_first_page_bsi_'
    click_button('search-submit-newspapers')
    within "#search-results" do
      expect(page).to have_content "#{title2_issue1_title_memo}: Page 1"
      expect(page).not_to have_content "#{title1_issue1_title_memo}: Page 2"
    end
  end

  it 'returns correct results for keyword search with date' do
    fill_in "date_range_start", with: '1965'
    fill_in "date_range_end", with: '1966'
    click_button('search-submit-newspapers')
    within "#search-results" do
      expect(page).to have_content "#{title1_issue1_title_memo}: Page 1"
      expect(page).not_to have_content "#{title2_issue1_title_memo}: Page 1"
    end
  end

  it 'returns correct results for keyword search with facet' do
    check 'f_inclusive_language_sim_spanish'
    click_button('search-submit-newspapers')
    within "#search-results" do
      expect(page).to have_content "#{title2_issue1_title_memo}: Page 1"
      expect(page).not_to have_content "#{title1_issue1_title_memo}: Page 1"
    end
  end
end
