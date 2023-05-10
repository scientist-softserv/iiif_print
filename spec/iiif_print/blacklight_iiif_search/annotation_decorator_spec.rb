require 'spec_helper'

RSpec.describe IiifPrint::BlacklightIiifSearch::AnnotationDecorator do
  let(:parent_id) { 'abc123' }
  let(:page_document) do
    doc = build(:newspaper_page_solr_document)
    doc['is_page_of_ssim'] = [parent_id]
    doc
  end
  let(:controller) { CatalogController.new }
  let(:coordinates) do
    JSON.parse("{\"coords\":{\"software\":[[2641,4102,512,44]]}}")
  end
  let(:parent_document) do
    SolrDocument.new('id' => parent_id,
                     'has_model_ssim' => ['NewspaperIssue'])
  end
  let(:iiif_search_annotation) do
    BlacklightIiifSearch::IiifSearchAnnotation.new(page_document, 'software',
                                                   0, nil, controller,
                                                   parent_document)
  end
  let(:test_request) { ActionDispatch::TestRequest.new({}) }

  before do
    allow(controller).to receive(:request).and_return(test_request)
    allow(controller).to receive(:polymorphic_url)
      .with(parent_document, host: test_request.base_url, locale: nil)
      .and_return("/#{page_document[:issue_id_ssi]}")
  end

  describe '#annotation_id' do
    subject { iiif_search_annotation.annotation_id }
    it 'returns a properly formatted URL' do
      expect(subject).to include("#{page_document[:issue_id_ssi]}/manifest/canvas/#{page_document[:file_set_ids_ssim].first}/annotation/0")
    end
  end

  describe '#canvas_uri_for_annotation' do
    before { allow(iiif_search_annotation).to receive(:fetch_and_parse_coords).and_return(coordinates) }

    subject { iiif_search_annotation.canvas_uri_for_annotation }
    it 'returns a properly formatted URL' do
      expect(subject).to include("#{page_document[:issue_id_ssi]}/manifest/canvas/#{page_document[:file_set_ids_ssim].first}")
    end

    describe 'private methods' do
      # test #coordinates based on output of #canvas_uri_for_annotation, which calls it
      describe '#coordinates' do
        it 'gets the expected value from #coordinates' do
          expect(subject).to include("#xywh=2641,4102,512,44")
        end
      end
    end
  end
end
