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

  context 'with IIIF external support' do
    let(:presenter) { Hyrax::IiifManifestPresenter::DisplayImagePresenter.new(solr_document) }
    let(:id) { 'abc123' }
    let(:url) { 'external_iiif_url' }
    let(:iiif_info_url_builder) { ->(file_id, base_url) { "#{base_url}/#{file_id}" } }

    before { allow(solr_document).to receive(:image?).and_return(true) }

    context 'when external iiif is enabled' do
      before do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('EXTERNAL_IIIF_URL').and_return(url)
        allow(presenter).to receive(:latest_file_id).and_return(id)
      end

      describe '#display_image' do
        it 'renders a external url' do
          expect(presenter.display_image.iiif_endpoint.url).to eq "#{url}/#{id}"
          expect(presenter.display_image.iiif_endpoint.profile).to eq "http://iiif.io/api/image/2/level2.json"
        end
      end

      describe '#display_content' do
        it 'renders a external url' do
          expect(presenter.display_content.iiif_endpoint.url).to eq "#{url}/#{id}"
          expect(presenter.display_content.iiif_endpoint.profile).to eq "http://iiif.io/api/image/2/level2.json"
        end
      end
    end

    context 'when external iiif is not enabled' do
      before do
        allow(presenter).to receive(:latest_file_id).and_return(id)
        allow(Hyrax.config).to receive(:iiif_image_server?).and_return(true)
        allow(Hyrax.config).to receive(:iiif_info_url_builder).and_return(iiif_info_url_builder)
      end

      describe '#display_image' do
        it 'does not render a external url' do
          expect(presenter.display_image.iiif_endpoint.url).to eq "localhost/#{id}"
        end
      end

      describe '#display_content' do
        it 'does not render a external url' do
          expect(presenter.display_content.iiif_endpoint.url).to eq "localhost/#{id}"
        end
      end
    end
  end
end
