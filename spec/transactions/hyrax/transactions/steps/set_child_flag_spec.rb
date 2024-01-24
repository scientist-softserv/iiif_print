# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hyrax::Transactions::Steps::SetChildFlag do
  class Work < Hyrax::Work
    include Hyrax::Schema(:child_works_from_pdf_splitting)
  end
  let(:parent_work) do
    parent_work = Work.new
    parent_work.title = ['Parent Work']
    Hyrax.persister.save(resource: parent_work)
  end
  let(:child_work) do
    child_work = Work.new
    child_work.title = ['Child Work']
    Hyrax.persister.save(resource: child_work)
  end

  before do
    parent_work.member_ids << child_work.id
    Hyrax.persister.save(resource: parent_work)
    Hyrax.index_adapter.save(resource: parent_work)
  end

  describe '#call' do
    subject { described_class.new.call(parent_work) }

    it 'sets the is_child flag on the child work' do
      allow(::User).to receive(:find_by_user_key).and_return('user')
      expect(child_work.is_child).to be nil
      subject
      # gets a reloaded version of the child work
      expect(Hyrax.query_service.find_by(id: child_work.id).is_child).to be true
    end
  end
end
