require 'spec_helper'

RSpec.describe 'newspaper_works/newspapers_search/search.html.erb', type: :view do
  let(:search_params) { CatalogController.blacklight_config.advanced_search.newspapers_search[:form_solr_parameters] }

  # create some fixtures, so we have facets to display
  before(:all) do
    issue1 = NewspaperIssue.new
    issue1.title = ['Foo']
    issue1.resource_type = ["newspaper"]
    issue1.language = ["English"]
    issue1.held_by = "Marriott Library"
    page1 = NewspaperPage.new
    page1.title = ['Page 1']
    issue1.ordered_members << page1
    issue1.save!
    page1.save!
  end

  before do
    allow(view).to receive(:current_search_parameters).and_return(nil)
    assign(:response, Blacklight.default_index.search(search_params))
    render
  end

  describe 'partial rendering' do
    it 'renders the newspapers_search_form partial' do
      expect(rendered).to render_template(partial: 'newspaper_works/newspapers_search/_newspapers_search_form')
    end

    it 'renders the newspapers_search_help partial' do
      expect(rendered).to render_template(partial: 'newspaper_works/newspapers_search/_newspapers_search_help')
    end
  end

  describe 'rendered elements' do
    it 'renders the keyword input' do
      expect(rendered).to have_selector("input#all_fields")
    end

    it 'renders the front pages input' do
      expect(rendered).to have_selector("input.front_pages_checkbox")
    end

    it 'renders the date inputs' do
      expect(rendered).to have_selector("input#date_range_start")
      expect(rendered).to have_selector("input#date_range_end")
    end

    it 'renders the facet selectors' do
      expect(rendered).to have_selector("input#f_inclusive_language_sim_english")
    end
  end
end
