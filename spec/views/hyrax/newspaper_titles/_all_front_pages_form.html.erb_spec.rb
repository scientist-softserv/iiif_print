require 'spec_helper'
RSpec.describe 'hyrax/newspaper_titles/_all_front_pages_form.html.erb', type: :view do
  let(:presenter) { double }

  before do
    allow(presenter).to receive(:front_page_search_params).and_return(f: { "publication_title_ssi" => ["Wall Street Journal"], "first_page_bsi" => [true] })
    assign(:presenter, presenter)
    render
  end

  let(:page) { Capybara::Node::Simple.new(rendered) }

  it "has a link to the front pages view" do
    expect(page).to have_link("View all front pages", href: main_app.search_catalog_path(presenter.front_page_search_params))
  end
end
