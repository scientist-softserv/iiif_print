require 'spec_helper'
RSpec.describe IiifPrint::PageFinder do
  # use before(:all) so we only create fixtures once
  before(:all) do
    @issue = NewspaperIssue.new
    @issue.title = ["Yesterday's News: December 7, 1941"]

    @page1 = NewspaperPage.new
    @page1.title = ['Page 1']
    @page2 = NewspaperPage.new
    @page2.title = ['Page 2']
    @page3 = NewspaperPage.new
    @page3.title = ['Page 3']

    @issue.ordered_members << @page1
    @issue.ordered_members << @page2
    @issue.ordered_members << @page3

    @issue.save!
    @page1.save!
    @page2.save!
    @page3.save!

    @page1_solr_doc = SolrDocument.find(@page1.id)
    @page2_solr_doc = SolrDocument.find(@page2.id)
    @page3_solr_doc = SolrDocument.find(@page3.id)
  end

  let(:controller) { IiifPrint::NewspapersController.new }

  let(:ordered_pages_array) { [@page1_solr_doc, @page2_solr_doc, @page3_solr_doc] }

  describe 'pages_for_issue' do
    subject { controller.pages_for_issue(@issue.id) }
    it 'returns the pages, in order' do
      # for some reason, the line below doesn't work, so we compare ids
      # expect(subject).to eq ordered_pages_array
      expect(subject[0]['id']).to eq ordered_pages_array[0]['id']
      expect(subject[1]['id']).to eq ordered_pages_array[1]['id']
      expect(subject[2]['id']).to eq ordered_pages_array[2]['id']
    end
  end

  describe '#ordered_pages' do
    subject { controller.ordered_pages(ordered_pages_array.shuffle) }
    it { is_expected.to eq ordered_pages_array }
  end

  describe '#get_page_index' do
    subject { controller.get_page_index(@page2.id) }
    it { is_expected.to eq 1 }
  end
end
