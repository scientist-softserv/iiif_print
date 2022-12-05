require 'spec_helper'
require 'ndnp_shared'

RSpec.describe IiifPrint::Ingest::NDNP::BatchIngester do
  include_context "ndnp fixture setup"

  describe "adapter construction" do
    it "loads batch to operate on" do
      adapter = described_class.new(batch1)
      expect(adapter.batch).to be_a IiifPrint::Ingest::NDNP::BatchXMLIngest
      expect(adapter.batch.path).to eq adapter.path
    end

    it "finds batch xml, if given path containing batch" do
      parent_path = File.dirname(batch1)
      adapter = described_class.new(parent_path)
      expect(adapter.path).to eq batch1
      expect(adapter.batch.path).to eq adapter.path
    end

    it "constructs adapter with hash options" do
      user = User.batch_user.user_key
      adapter = described_class.new(
        batch1,
        depositor: user
      )
      expect(adapter.opts[:depositor]).to eq user
    end
  end

  describe "ingests issues" do
    def expect_start_finish_logging(adapter)
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('Beginning NDNP batch ingest') }
      ).once
      expect(adapter).to receive(:write_log).with(
        satisfy { |v| v.include?('NDNP batch ingest complete') }
      ).once
    end

    it "calls ingest for all issues in batch" do
      adapter = described_class.new(batch1)
      issue_ingest_call_count = 0
      # rubocop:disable RSpec/AnyInstance (we really need to stub this way)
      allow_any_instance_of(IiifPrint::Ingest::NDNP::IssueIngester).to \
        receive(:ingest) { issue_ingest_call_count += 1 }
      # rubocop:enable RSpec/AnyInstance
      expect_start_finish_logging(adapter)
      adapter.ingest
      expect(issue_ingest_call_count).to eq 4
    end
  end

  describe "command invocation" do
    def construct(args)
      described_class.from_command(
        args,
        'rake iiif_print:ingest_ndnp --'
      )
    end

    let(:fake_argv) do
      [
        'iiif_print:ingest_ndnp',
        '--',
        "--path=#{batch1}"
      ]
    end

    let(:fake_argv2) do
      [
        'iiif_print:ingest_ndnp',
        '--',
        "--path=#{batch1}",
        "--admin_set=admin_set/default",
        "--depositor=#{User.batch_user.user_key}",
        "--visibility=open"
      ]
    end

    it "creates ingester from command arguments" do
      adapter = construct(fake_argv)
      expect(adapter).to be_a described_class
      expect(adapter.path).to eq batch1
    end

    it "creates ingester from expanded command arguments" do
      adapter = construct(fake_argv2)
      expect(adapter).to be_a described_class
      expect(adapter.path).to eq batch1
      expect(adapter.opts[:depositor]).to eq User.batch_user.user_key
      expect(adapter.opts[:visibility]).to eq 'open'
      expect(adapter.opts[:admin_set]).to eq 'admin_set/default'
    end

    it "creates ingester from command with dir path" do
      # command can accept a parent directory for batch:
      base_path = File.dirname(batch1)
      fake_argv = ['iiif_print:ingest_ndnp', '--', "--path=#{base_path}"]
      adapter = construct(fake_argv)
      expect(adapter).to be_a described_class
      # adapter.path is path to actual XML
      expect(adapter.path).to eq batch1
    end

    it "exits on file not found for batch" do
      fake_argv = ['iiif_print:ingest_ndnp', '--', "--path=123/45/5678"]
      begin
        construct(fake_argv)
      rescue SystemExit => e
        expect(e.status).to eq(1)
      end
    end

    it "exits on missing path for batch" do
      fake_argv = ['iiif_print:ingest_ndnp', '--']
      begin
        construct(fake_argv)
      rescue SystemExit => e
        expect(e.status).to eq(1)
      end
    end

    it "exits on unexpected arguments" do
      fake_argv = ['iiif_print:ingest_ndnp', '--', '--foo=bar']
      expect { construct(fake_argv) }.to raise_error(
        OptionParser::InvalidOption
      )
    end
  end
end
