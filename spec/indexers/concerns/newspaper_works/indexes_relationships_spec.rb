require 'spec_helper'
require 'model_shared'

RSpec.describe NewspaperWorks::IndexesRelationships do
  # use an instance var so we can create fixtures only once
  # rubocop:disable RSpec/InstanceVariable
  before(:all) { @page_for_indexrel = model_fixtures(NewspaperPage) }
  let(:page_indexer) { NewspaperPageIndexer.new(@page_for_indexrel) }

  describe '#index_relationships' do
    let(:solr_doc) { {} }
    before { page_indexer.index_relationships(@page_for_indexrel, solr_doc) }
    it 'sets the relationship fields correctly' do
      expect(solr_doc['publication_id_ssi']).not_to be_falsey
      expect(solr_doc['container_id_ssi']).not_to be_falsey
      expect(solr_doc['issue_id_ssi']).not_to be_falsey
      expect(solr_doc['article_ids_ssim']).not_to be_falsey
    end
  end

  describe '#index_publication_title' do
    let(:solr_doc) { {} }
    before { page_indexer.index_publication_title(@page_for_indexrel, solr_doc) }
    it 'sets the publication title fields correctly' do
      expect(solr_doc['publication_id_ssi']).not_to be_falsey
      expect(solr_doc['publication_title_ssi']).to eq("Yesterday's News")
    end
  end

  describe '#index_container' do
    let(:solr_doc) { {} }
    before { page_indexer.index_container(@page_for_indexrel, solr_doc) }
    it 'sets the container fields correctly' do
      expect(solr_doc['container_id_ssi']).not_to be_falsey
      expect(solr_doc['container_title_ssi']).to eq('Reel123a')
    end
  end

  describe '#index_issue' do
    let(:solr_doc) { {} }
    before { page_indexer.index_issue(@page_for_indexrel, solr_doc) }
    it 'sets the issue fields correctly' do
      expect(solr_doc['issue_id_ssi']).not_to be_falsey
      expect(solr_doc['issue_title_ssi']).to eq('December 7, 1941')
    end
  end

  describe '#index_pages' do
    let(:article) { @page_for_indexrel.articles.first }
    let(:article_indexer) { NewspaperArticleIndexer.new(article) }
    let(:solr_doc) { {} }
    before { page_indexer.index_pages(article, solr_doc) }
    it 'sets the issue fields correctly' do
      expect(solr_doc['page_ids_ssim'].first).to eq(@page_for_indexrel.id)
      expect(solr_doc['page_titles_ssim'].first).to eq('Page 1')
    end
  end

  describe '#index_articles' do
    let(:solr_doc) { {} }
    before { page_indexer.index_articles(@page_for_indexrel, solr_doc) }
    it 'sets the article fields correctly' do
      expect(solr_doc['article_ids_ssim']).not_to be_blank
      expect(solr_doc['article_titles_ssim'].first).to eq('Happening now')
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
