# hyrax/spec/views/hyrax/base/_attribute_rows.html.erb_spec.rb
require 'spec_helper'

RSpec.describe 'newspaper_works/base/_attribute_rows.html.erb', type: :view do
  let(:url) { "http://example.com" }
  let(:title) { "There and Back Again" }
  let(:issn) { "2049-3630" }
  let(:place_of_publication_label) { "Salt Lake City, Utah, United States" }
  let(:publication_date) { "2019-01-24" }
  let(:rights_statement_uri) { 'http://rightsstatements.org/vocab/InC/1.0/' }
  let(:ability) { double }
  let(:request) { double(host: 'example.org') }
  let(:work) do
    stub_model(NewspaperIssue,
               title: [title],
               issn: issn,
               place_of_publication_label: [place_of_publication_label],
               publication_date: [publication_date],
               related_url: [url],
               rights_statement: [rights_statement_uri])
  end
  let(:solr_document) do
    SolrDocument.new(has_model_ssim: 'NewspaperIssue',
                     title_tesim: [title],
                     issn_tesim: [issn],
                     place_of_publication_label_tesim: [place_of_publication_label],
                     publication_date_dtsim: [publication_date],
                     rights_statement_tesim: [rights_statement_uri],
                     related_url_tesim: [url],
                     publication_unique_id_ssi: 'sn1234567')
  end

  let(:presenter) { Hyrax::NewspaperIssuePresenter.new(solr_document, ability, request) }

  let(:page) do
    render 'newspaper_works/base/attribute_rows', presenter: presenter
    Capybara::Node::Simple.new(rendered)
  end

  it 'shows issn of the work' do
    expect(page).to have_text("2049-3630")
  end

  it 'shows place of publication label of the work' do
    expect(page).to have_text("Place of publication label")
    expect(page).to have_text("Salt Lake City, Utah, United States")
  end

  it 'shows publication date of the work' do
    expect(page).to have_text("01/24/2019")
  end

  it 'shows rights statement with link to statement URL' do
    expect(page).to have_link("In Copyright", href: rights_statement_uri)
  end

  it 'shows the permalink' do
    expect(page).to have_text('/newspapers/sn1234567/2019-01-24/ed-1')
  end
end
