require 'spec_helper'
RSpec.describe 'iiif_print/base/_show.html.erb', type: :view do
  let(:work_solr_document) do
    SolrDocument.new(id: '999',
                     title_tesim: ['My Title'],
                     creator_tesim: ['Doe, John', 'Doe, Jane'],
                     date_modified_dtsi: '2011-04-01',
                     has_model_ssim: ['NewspaperIssue'],
                     depositor_tesim: depositor.user_key,
                     description_tesim: ['Lorem ipsum lorem ipsum.'],
                     keyword_tesim: ['bacon', 'sausage', 'eggs'],
                     rights_statement_tesim: ['http://example.org/rs/1'],
                     date_created_tesim: ['2019-01-02'])
  end

  let(:file_set_solr_document) do
    SolrDocument.new(id: '123',
                     title_tesim: ['My FileSet'],
                     depositor_tesim: depositor.user_key)
  end

  let(:ability) { double }

  let(:presenter) do
    Hyrax::NewspaperIssuePresenter.new(work_solr_document, ability, request)
  end

  let(:workflow_presenter) do
    double('workflow_presenter', badge: 'Foobar')
  end

  let(:representative_presenter) do
    Hyrax::FileSetPresenter.new(file_set_solr_document, ability)
  end

  let(:page) { Capybara::Node::Simple.new(rendered) }

  let(:request) { double('request', host: 'test.host') }

  let(:depositor) do
    stub_model(User,
               user_key: 'bob',
               twitter_handle: 'bot4lib')
  end

  before do
    allow(presenter).to receive(:workflow).and_return(workflow_presenter)
    allow(presenter).to receive(:representative_presenter).and_return(representative_presenter)
    allow(presenter).to receive(:representative_id).and_return('123')
    allow(presenter).to receive(:tweeter).and_return("@#{depositor.twitter_handle}")
    allow(presenter).to receive(:human_readable_type).and_return("Work")
    allow(controller).to receive(:current_user).and_return(depositor)
    allow(User).to receive(:find_by_user_key).and_return(depositor.user_key)
    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:signed_in?)
    allow(view).to receive(:on_the_dashboard?).and_return(false)
    stub_template 'hyrax/base/_metadata.html.erb' => ''
    stub_template 'iiif_print/base/_relationships.html.erb' => ''
    stub_template 'hyrax/base/_show_actions.html.erb' => ''
    stub_template 'iiif_print/base/_social_media.html.erb' => ''
    stub_template 'iiif_print/base/_citations.html.erb' => ''
    stub_template 'iiif_print/base/_items.html.erb' => ''
    stub_template 'iiif_print/base/_representative_media.html.erb' => ''
    stub_template 'iiif_print/base/_workflow_actions_widget.html.erb' => ''
    stub_template 'iiif_print/base/_work_description.html.erb' => ''
    stub_template 'iiif_print/base/_work_type.html.erb' => ''
    stub_template 'iiif_print/base/_work_title.html.erb' => ''
    stub_template '_masthead.html.erb' => ''
    stub_template 'iiif_print/base/_newspaper_hierarchy.html.erb' => ''
    assign(:presenter, presenter)
    # render template: 'hyrax/base/show.html.erb', layout: 'layouts/hyrax/1_column'
  end

  it 'shows the issue search form partial' do
    render
    expect(rendered).to render_template(partial: 'iiif_print/base/_newspaper_hierarchy')
  end
end
