require 'spec_helper'

RSpec.describe IiifPrint::IiifManifestPresenterBehavior do
  let(:attributes) do
    { "id" => "abc123",
      "title_tesim" => ['Page the first'],
      "description_tesim" => ['A book or something'],
      "creator_tesim" => ['Arthur McAuthor'] }
  end
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:presenter) { Hyrax::IiifManifestPresenter.new(solr_document) }
  let(:test_request) { ActionDispatch::TestRequest.new({}) }

  describe '#search_service' do
    it 'returns the correct URL for the IIIF Search service' do
      expect(presenter.search_service).to include("#{solr_document.id}/iiif_search")
    end
  end

  # this method is inside of the DisplayImagePresenterBehavior module
  describe '#display_image' do
    let(:presenter) { Hyrax::IiifManifestPresenter::DisplayImagePresenter.new(solr_document) }
    let(:id) { 'abc123' }

    context 'when serverless_iiif is enabled' do
      let(:url) { 'serverless_iiif_url' }

      it 'renders a serverless url' do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('SERVERLESS_IIIF_URL').and_return(url)
        allow(presenter).to receive(:latest_file_id).and_return(id)
        expect(presenter.display_image.iiif_endpoint.url).to eq "#{url}/#{id}"
        expect(presenter.display_image.iiif_endpoint.profile).to eq "http://iiif.io/api/image/2/level2.json"
      end
    end

    context 'when serverless_iiif is not enabled' do
      let(:iiif_info_url_builder) { ->(file_id, base_url) { "#{base_url}/#{file_id}" } }

      it 'does not render a serverless url' do
        allow(presenter).to receive(:latest_file_id).and_return(id)
        allow(Hyrax.config).to receive(:iiif_image_server?).and_return(true)
        allow(Hyrax.config).to receive(:iiif_info_url_builder).and_return(iiif_info_url_builder)
        expect(presenter.display_image.iiif_endpoint.url).to eq "localhost/#{id}"
      end
    end
  end
end
