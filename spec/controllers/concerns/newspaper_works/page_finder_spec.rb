require 'spec_helper'
RSpec.describe NewspaperWorks::PageFinder do
  let(:page1) do
    SolrDocument.new('id' => 'page1',
                     'has_model_ssim' => ['NewspaperPage'],
                     'is_preceding_page_of_ssi' => 'page2')
  end
  let(:page2) do
    SolrDocument.new('id' => 'page2',
                     'has_model_ssim' => ['NewspaperPage'],
                     'is_following_page_of_ssi' => 'page1',
                     'is_preceding_page_of_ssi' => 'page3')
  end
  let(:page3) do
    SolrDocument.new('id' => 'page3',
                     'has_model_ssim' => ['NewspaperPage'],
                     'is_following_page_of_ssi' => 'page2')
  end
  let(:documents) { [page2, page3, page1] }
  let(:controller) { NewspaperWorks::NewspapersController.new }

  describe '#ordered_pages' do
    subject { controller.ordered_pages(documents) }
    it { is_expected.to eq([page1, page2, page3]) }
  end
end
