require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperPageIndexer do
  include_context "shared setup"

  let(:indexer) { described_class.new(sample_work) }
  let(:solr_document) { indexer.generate_solr_document }

  describe "generates correct solr_document" do
    it "makes a solr_document with full text to index" do
      work = sample_work
      mk_txt_derivative(work)
      doc = solr_document
      expect(doc.keys).to include 'all_text_timv'
      expect(doc['all_text_timv']).to eq sample_text
    end
  end

  describe "indexes searchable fulltext" do
    it "makes a solr_document with full text to index" do
      work = sample_work
      mk_txt_derivative(work)
      # save will trigger indexing
      expect(work.save).to be true
      # ...and we expect full text to be indexed:
      result = NewspaperPage.where(all_text_timv: 'enigmas')
      expect(result).to include work
    end
  end
end
