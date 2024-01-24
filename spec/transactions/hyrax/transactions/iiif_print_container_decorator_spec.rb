# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hyrax::Transactions::Container do
  describe 'file_set.destroy' do
    subject(:transaction_step) { described_class['file_set.destroy'] }
    describe '#steps' do
      subject { transaction_step.steps }
      it {
        is_expected.to match_array(["file_set.iiif_print_conditionally_destroy_spawned_children",
                                    "file_set.remove_from_work",
                                    "file_set.delete"])
      }
    end
  end

  describe 'file_set.iiif_print_conditionally_destroy_spawned_children' do
    subject(:transaction_step) { described_class['file_set.iiif_print_conditionally_destroy_spawned_children'] }
    it { is_expected.to be_a Hyrax::Transactions::Steps::ConditionallyDestroyChildrenFromSplit }
  end

  describe 'change_set.update_work' do
    subject(:transaction_step) { described_class['change_set.update_work'] }
    it 'has the correct steps' do
      expect(transaction_step.steps).to match_array(["change_set.apply",
                                                     "work_resource.save_acl",
                                                     "work_resource.add_file_sets",
                                                     "work_resource.update_work_members",
                                                     "work_resource.set_child_flag"])
    end
  end

  describe 'work_resource.set_child_flag' do
    subject(:transaction_step) { described_class['work_resource.set_child_flag'] }
    it { is_expected.to be_a Hyrax::Transactions::Steps::SetChildFlag }
  end
end
