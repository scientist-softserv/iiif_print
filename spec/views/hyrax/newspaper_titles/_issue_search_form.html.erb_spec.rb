require 'spec_helper'
RSpec.describe 'hyrax/newspaper_titles/_issue_search_form.html.erb', type: :view do
  let(:presenter) { double }

  before do
    allow(view).to receive(:search_form_action).and_return("/catalog")
    allow(view).to receive(:search_state).and_return(search_state)
    allow(view).to receive(:current_search_parameters).and_return(nil)
    allow(view).to receive(:current_user).and_return(nil)

    allow(presenter).to receive(:title_search_params).and_return(f: { "publication_title_ssi" => ["Wall Street Journal"] })
    assign(:presenter, presenter)
    render
  end
  let(:search_state) { double('SearchState', params_for_search: {}) }
  let(:page) { Capybara::Node::Simple.new(rendered) }

  it "has a hidden `f[publication_title_ssi][]` form field" do
    expect(page).to have_selector("[name='f\[publication_title_ssi\]\[\]'][value='Wall Street Journal']", visible: false)
  end

  it "has hidden `all_fields` form field" do
    expect(page).to have_selector("[name='search_field'][value='all_fields']", visible: false)
  end

  it "has a `q` form field for query" do
    expect(page).to have_field("q")
  end
end
