require 'spec_helper'
RSpec.describe NewspaperWorks::BlacklightIiifSearch::AnnotationBehavior do
  let(:parent_id) { 'abc123' }
  let(:file_set_id) { '987654' }
  let(:page_document) do
    SolrDocument.new('id' => 'hijklm',
                     'issue_id_ssi' => parent_id,
                     'file_set_ids_ssim' => [file_set_id])
  end
  let(:controller) { CatalogController.new }
  let(:coordinates) do
    "{\"words\":[{\"word\":\"software\",\"coordinates\":[2641,4102,512,44]}]}"
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

  before { allow(controller).to receive(:request).and_return(test_request) }

  describe '#annotation_id' do
    subject { iiif_search_annotation.annotation_id }
    it 'returns a properly formatted URL' do
      expect(subject).to include("#{parent_id}/manifest/canvas/#{file_set_id}/annotation/0")
    end
  end

  describe '#canvas_uri_for_annotation' do
    before { allow(iiif_search_annotation).to receive(:coordinates_raw).and_return(coordinates) }

    subject { iiif_search_annotation.canvas_uri_for_annotation }
    it 'returns a properly formatted URL' do
      expect(subject).to include("#{parent_id}/manifest/canvas/#{file_set_id}")
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
