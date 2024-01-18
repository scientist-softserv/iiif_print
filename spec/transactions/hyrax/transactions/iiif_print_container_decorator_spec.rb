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
end
