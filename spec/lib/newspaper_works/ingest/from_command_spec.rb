require 'spec_helper'
require 'newspaper_works_fixtures'

RSpec.describe NewspaperWorks::Ingest::FromCommand do
  include_context "ingest test fixtures"

  describe "alternate construction" do
    let(:klass) do
      Class.new do
        extend NewspaperWorks::Ingest::FromCommand

        attr_accessor :path, :opts

        def initialize(path, opts = {})
          @path = path
          @opts = opts
        end
      end
    end

    def construct(args)
      klass.from_command(
        args,
        'rake newspaper_works:ingest_pdf_issues --'
      )
    end

    let(:lccn) { 'sn93059126' }

    let(:fake_argv) do
      [
        'newspaper_works:ingest_pdf_issues',
        '--',
        "--path=#{pdf_fixtures}"
      ]
    end

    let(:more_argv) do
      fake_argv + [
        "--lccn=#{lccn}"
      ]
    end

    let(:most_argv) do
      more_argv + [
        "--admin_set=admin_set/default",
        "--depositor=#{User.batch_user.user_key}",
        "--visibility=open"
      ]
    end

    it "calls constructor with minimal options parsed" do
      ingester = construct(fake_argv)
      expect(ingester.path).to eq pdf_fixtures
      expect(ingester.opts[:path]).to eq pdf_fixtures
    end

    it "calls constructor with explict lccn option" do
      ingester = construct(more_argv)
      expect(ingester.path).to eq pdf_fixtures
      expect(ingester.opts[:lccn]).to eq lccn
    end

    it "calls constructor with all options" do
      ingester = construct(most_argv)
      expect(ingester.path).to eq pdf_fixtures
      expect(ingester.opts[:lccn]).to eq lccn
      expect(ingester.opts[:admin_set]).to eq 'admin_set/default'
      expect(ingester.opts[:depositor]).to eq User.batch_user.user_key
      expect(ingester.opts[:visibility]).to eq 'open'
    end
  end
end
