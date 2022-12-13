# require 'spec_helper'
# require 'model_shared'

# RSpec.describe IiifPrint::IndexesRelationships do
#   # use an instance var so we can create fixtures only once
#   before(:all) { @page_for_indexrel, @page2 = model_fixtures(:newspaper_pages) }
#   let(:page_indexer) { NewspaperPageIndexer.new(@page_for_indexrel) }
#   let(:solr_doc) { {} }

#   describe '#index_relationships' do
#     before { page_indexer.index_relationships(@page_for_indexrel, solr_doc) }
#     it 'sets the relationship fields correctly' do
#       expect(solr_doc['publication_id_ssi']).not_to be_falsey
#       expect(solr_doc['container_id_ssi']).not_to be_falsey
#       expect(solr_doc['issue_id_ssi']).not_to be_falsey
#       expect(solr_doc['article_ids_ssim']).not_to be_falsey
#     end
#   end

#   describe '#index_publication' do
#     before { page_indexer.index_publication(@page_for_indexrel, solr_doc) }
#     it 'sets the publication title fields correctly' do
#       expect(solr_doc['publication_id_ssi']).not_to be_falsey
#       expect(solr_doc['publication_title_ssi']).to eq("Yesterday's News")
#       expect(solr_doc['publication_unique_id_ssi']).to eq("sn1234567")
#     end
#   end

#   describe '#index_container' do
#     before { page_indexer.index_container(@page_for_indexrel, solr_doc) }
#     it 'sets the container fields correctly' do
#       expect(solr_doc['container_id_ssi']).not_to be_falsey
#       expect(solr_doc['container_title_ssi']).to eq('Reel123a')
#     end
#   end

#   describe '#index_issue' do
#     before { page_indexer.index_issue(@page_for_indexrel, solr_doc) }
#     it 'sets the issue fields correctly' do
#       expect(solr_doc['issue_id_ssi']).not_to be_falsey
#       expect(solr_doc['issue_title_ssi']).to eq('December 7, 1941')
#       expect(solr_doc['issue_edition_number_ssi']).to eq('1')
#       expect(solr_doc['publication_date_dtsi']).to eq('1941-12-07T00:00:00Z')
#     end
#   end

#   describe '#index_pages' do
#     let(:article) { @page_for_indexrel.articles.first }
#     let(:article_indexer) { NewspaperArticleIndexer.new(article) }
#     before { page_indexer.index_pages(article, solr_doc) }
#     it 'sets the issue fields correctly' do
#       expect(solr_doc['page_ids_ssim'].first).to eq(@page_for_indexrel.id)
#       expect(solr_doc['page_titles_ssim'].first).to eq('Page 1')
#     end
#   end

#   describe '#index_siblings' do
#     let(:solr_doc_2) { {} }
#     before do
#       page_indexer.index_siblings(@page_for_indexrel, solr_doc)
#       page_indexer.index_siblings(@page2, solr_doc_2)
#     end
#     it 'sets the prev/next fields correctly' do
#       expect(solr_doc['is_preceding_page_of_ssi']).not_to be_falsey
#       expect(solr_doc['is_following_page_of_ssi']).to be_nil
#       expect(solr_doc['first_page_bsi']).to be_truthy
#       expect(solr_doc_2['is_preceding_page_of_ssi']).to be_nil
#       expect(solr_doc_2['is_following_page_of_ssi']).not_to be_falsey
#     end
#   end

#   describe '#index_articles' do
#     before { page_indexer.index_articles(@page_for_indexrel, solr_doc) }
#     it 'sets the article fields correctly' do
#       expect(solr_doc['article_ids_ssim']).not_to be_blank
#       expect(solr_doc['article_titles_ssim'].first).to eq('Happening now')
#     end
#   end

#   describe '#index_parent_facets' do
#     before { page_indexer.index_parent_facets(@page_for_indexrel.issue, solr_doc) }
#     it 'sets the facet fields correctly' do
#       expect(solr_doc['language_sim']).not_to be_blank
#     end
#   end
# end
