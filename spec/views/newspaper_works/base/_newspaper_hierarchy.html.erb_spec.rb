require 'spec_helper'
include NewspaperWorks::BreadcrumbHelper
include Hyrax::NewspaperPagesHelper
RSpec.describe 'newspaper_works/base/_newspaper_hierarchy.html.erb', type: :view do
  let(:url) { "http://example.com" }
  let(:title) { "2018-05-18: Page 1" }
  let(:issn) { "2049-3630" }
  let(:place_of_publication_label) { "Salt Lake City, Utah, United States" }
  let(:publication_date) { "2019-01-24" }
  let(:rights_statement_uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
  let(:ability) { double }
  let(:request) { double(host: 'example.org') }

  let(:solr_document) do
    SolrDocument.new(has_model_ssim: 'NewspaperPage',
                     title_tesim: [title],
                     issn_tesim: [issn],
                     place_of_publication_label_tesim: [place_of_publication_label],
                     publication_date_dtsim: [publication_date],
                     rights_statement_tesim: [rights_statement_uri],
                     related_url_tesim: [url],
                     publication_unique_id_ssi: 'sn1234567')
  end

  let(:presenter) { Hyrax::NewspaperPagePresenter.new(solr_document, ability, request) }

  before do
    allow(presenter).to receive(:publication_id).and_return("pub_id")
    allow(presenter).to receive(:publication_title).and_return("Wall Street Journal")
    allow(presenter).to receive(:issue_id).and_return("iss_id")
    allow(presenter).to receive(:issue_title).and_return("2018-05-18")
  end

  it 'displays a link to the title in the breadcrumbs' do
    render partial: "newspaper_hierarchy.html.erb", locals: { presenter: presenter }
    expect(rendered).to include('href="/concern/newspaper_titles/pub_id"')
    expect(rendered).to have_content 'Wall Street Journal'
  end

  it 'displays a link to the issue in the breadcrumbs' do
    render partial: "newspaper_hierarchy.html.erb", locals: { presenter: presenter }
    expect(rendered).to include('href="/concern/newspaper_issues/iss_id"')
    expect(rendered).to have_content 'May 18, 2018'
  end

  it 'displays the page title in the breadcrumbs' do
    render partial: "newspaper_hierarchy.html.erb", locals: { presenter: presenter }
    expect(rendered).to have_content 'Page 1'
  end

  it 'displays page navigation if the presenter responds to :previous_page_id and :next_page_id)' do
    allow(presenter).to receive(:previous_page_id).and_return("prev_page_id")
    allow(presenter).to receive(:next_page_id).and_return("next_page_id")
    render partial: "newspaper_hierarchy.html.erb", locals: { presenter: presenter }
    expect(rendered).to include('href="/concern/newspaper_pages/prev_page_id"')
    expect(rendered).to include('href="/concern/newspaper_pages/next_page_id"')
    expect(rendered).to have_content 'Previous'
    expect(rendered).to have_content 'Next'
  end

  it 'displays displays `Next` without a link if `next_page_id` is nil' do
    allow(presenter).to receive(:previous_page_id).and_return("prev_page_id")
    allow(presenter).to receive(:next_page_id).and_return(nil)
    render partial: "newspaper_hierarchy.html.erb", locals: { presenter: presenter }
    expect(rendered).to include('href="/concern/newspaper_pages/prev_page_id"')
    expect(rendered).not_to include('href="/concern/newspaper_pages/next_page_id"')
    expect(rendered).to have_content 'Previous'
    expect(rendered).to have_content 'Next'
  end

  it 'displays displays `Previous` without a link if `next_page_id` is nil' do
    allow(presenter).to receive(:previous_page_id).and_return(nil)
    allow(presenter).to receive(:next_page_id).and_return("next_page_id")
    render partial: "newspaper_hierarchy.html.erb", locals: { presenter: presenter }
    expect(rendered).not_to include('href="/concern/newspaper_pages/prev_page_id"')
    expect(rendered).to include('href="/concern/newspaper_pages/next_page_id"')
    expect(rendered).to have_content 'Previous'
    expect(rendered).to have_content 'Next'
  end
end
