# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ApplicationHelper do
  let(:helper) { _view }

  let(:cname) { 'hyku-me.test' }
  let(:account) { build(:search_only_account, cname: cname) }

  let(:uuid) { SecureRandom.uuid }
  let(:request) do
    instance_double(ActionDispatch::Request,
                    port: 3000,
                    protocol: "https://",
                    host: account.cname,
                    params: { q: q })
  end
  let(:doc) { SolrDocument.new(id: uuid, 'has_model_ssim': ['GenericWork'], 'account_cname_tesim': account.cname) }

  before do
    allow(helper).to receive(:current_account) { account }
  end

  describe '#generate_work_url' do
    context 'when params has a "q" parameter' do
      let(:q) { "wonka-vision" }

      context 'when any_highlighting? is false' do
        it 'passes that along as :query' do
          expect(doc).to receive(:any_highlighting?).and_return(false)
          expect(helper.generate_work_url(doc, request)).to end_with("?query=#{q}")
        end
      end

      context 'when any_highlighting? is true' do
        it 'passes that along as :parent_query' do
          expect(doc).to receive(:any_highlighting?).and_return(true)
          expect(helper.generate_work_url(doc, request)).to end_with("?parent_query=#{q}")
        end
      end
    end
  end
end
