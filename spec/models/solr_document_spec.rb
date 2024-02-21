require 'spec_helper'
RSpec.describe SolrDocument do
  let(:solr_doc) { described_class.new(id: 'foo', member_ids_ssim: ['bar']) }

  describe 'file_set_ids' do
    it 'responds to #file_set_ids' do
      expect(solr_doc).to respond_to(:file_set_ids)
    end

    it 'returns the correct value' do
      expect(solr_doc.file_set_ids).to eq(['bar'])
    end
  end
end
