require 'spec_helper'
require 'misc_shared'

RSpec.describe IiifPrint::IndexesFullText do
  include_context "shared setup"

  let(:indexer) { NewspaperPageIndexer.new(sample_work) }
  let(:solr_document) { indexer.generate_solr_document }
  let(:work) { sample_work }

  before { mk_txt_derivative(work) }

  describe "#index_full_text" do
    before { indexer.index_full_text(work, solr_document) }
    it "makes a solr_document with full text to index" do
      expect(solr_document.keys).to include 'all_text_timv'
      expect(solr_document.keys).to include 'all_text_tsimv'
      expect(solr_document['all_text_tsimv']).to eq sample_text
    end
  end

  describe "fulltext discoverability" do
    it "returns the solr_document matching a query" do
      # save will trigger indexing
      expect(work.save).to be true
      # ...and we expect full text to be indexed:
      result = NewspaperPage.where(all_text_timv: 'enigmas')
      expect(result).to include work
    end
  end
end
