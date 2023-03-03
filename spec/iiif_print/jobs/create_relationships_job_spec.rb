require 'spec_helper'
require 'misc_shared'

RSpec.describe IiifPrint::Jobs::CreateRelationshipsJob do
  # TODO: add specs
  let(:parent) { WorkWithIiifPrintConfig.new(title: ['required title']) }
  let(:my_user) { build(:user) }
  let(:parent_model) { WorkWithIiifPrintConfig }
  let(:child_model) { WorkWithIiifPrintConfig }

  let(:subject) { described_class.perform(user: my_user, parent_id: parent.id, parent_model: parent_model, child_model: child_model) }

  describe '#perform' do
    xit 'loads all child work ids into ordered_members' do
    end
  end
end
