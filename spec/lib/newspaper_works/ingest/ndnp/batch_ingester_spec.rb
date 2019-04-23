require 'spec_helper'
require 'ndnp_shared'

RSpec.describe NewspaperWorks::Ingest::NDNP::BatchIngester do
  include_context "ndnp fixture setup"

  describe "adapter construction" do
    it "loads batch to operate on" do
      adapter = described_class.new(batch1)
      expect(adapter.batch).to be_a NewspaperWorks::Ingest::NDNP::BatchXMLIngest
      expect(adapter.batch.path).to eq adapter.path
    end

    it "finds batch xml, if given path containing batch" do
      parent_path = File.dirname(batch1)
      adapter = described_class.new(parent_path)
      expect(adapter.path).to eq batch1
      expect(adapter.batch.path).to eq adapter.path
    end
  end

  describe "ingests issues" do
    it "calls ingest for all issues in batch" do
      adapter = described_class.new(batch1)
      issue_ingest_call_count = 0
      # rubocop:disable RSpec/AnyInstance (we really need to stub this way)
      allow_any_instance_of(NewspaperWorks::Ingest::NDNP::IssueIngester).to \
        receive(:ingest) { issue_ingest_call_count += 1 }
      # rubocop:enable RSpec/AnyInstance
      adapter.ingest
      expect(issue_ingest_call_count).to eq 4
    end
  end
end
