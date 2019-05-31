require 'spec_helper'

RSpec.describe NewspaperWorks::NewspapersSearchController do
  describe 'GET "search"' do
    before { get :search }

    it 'renders the page' do
      expect(response).to be_successful
      expect(response).to render_template('newspaper_works/newspapers_search/search')
    end

    it 'sets the @response' do
      expect(assigns(:response)).to be_a_kind_of(Blacklight::Solr::Response)
    end
  end

  describe '#search_builder_class' do
    subject { controller.search_builder_class }
    it { is_expected.to eq NewspaperWorks::NewspapersSearchBuilder }
  end
end
