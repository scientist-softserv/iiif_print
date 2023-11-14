# frozen_string_literal: true

require 'spec_helper'
require 'misc_shared'

module IiifPrint::Jobs
  RSpec.describe CreateRelationshipsJob, type: :job do
    let(:create_relationships_job) { described_class.new }

    let(:parent_model) { WorkWithIiifPrintConfig.to_s }
    let(:child_model) { WorkWithIiifPrintConfig.to_s }
    let(:file) { FileSet.new.tap { |fs| fs.save!(validate: false) } }
    let(:parent_record) { WorkWithIiifPrintConfig.new(title: ['required title']) }
    let(:child_record1) { WorkWithIiifPrintConfig.new(title: ["Child of #{parent_record.id} page 01"]) }
    let(:child_record2) { WorkWithIiifPrintConfig.new(title: ["Child of #{parent_record.id} page 02"]) }
    let(:pending_rel1) { IiifPrint::PendingRelationship.new(
      parent_id: parent_record.id,
      child_title: "Child of #{parent_record.id} page 01",
      child_order: "Child of #{parent_record.id} page 01",
      parent_model: parent_model,
      child_model: child_model,
      file_id: file.id
    ) }
    let(:pending_rel2) { IiifPrint::PendingRelationship.new(
      parent_id: parent_record.id,
      child_title: "Child of #{parent_record.id} page 02",
      child_order: "Child of #{parent_record.id} page 02",
      parent_model: parent_model,
      child_model: child_model,
      file_id: file.id
    ) }

    describe '#perform' do
      before do
        allow(create_relationships_job).to receive(:acquire_lock_for).and_yield
        allow(create_relationships_job).to receive(:reschedule_job)
        allow(parent_record).to receive(:save!)

        parent_record.save
        pending_rel1.save
        pending_rel2.save
      end

      subject(:perform) do
        create_relationships_job.perform(
          parent_id: parent_record.id,
          parent_model: parent_model,
          child_model: child_model,
          retries: 0
        )
      end

      context 'when adding a child work to a parent work' do
        before do
          child_record1.save
          child_record2.save
        end

        it 'assigns the child to the parent\'s #ordered_members' do
          perform
          expect(parent_record.reload.ordered_member_ids).to eq([child_record1.id, child_record2.id])
        end

        it 'deletes the pending relationships' do
          expect { perform }.to change(IiifPrint::PendingRelationship, :count).by(-2)
        end

        it 'does not reschedule the job' do
          perform
          expect(create_relationships_job).not_to have_received(:reschedule_job)
        end
      end

      context 'when a relationship fails' do
        before do
          child_record1.save
          child_record2.save
        end

        before do
          expect_any_instance_of(CreateRelationshipsJob).to receive(:add_to_work).and_raise('error')
        end

        it 'does not save the parent' do
          expect { perform }.to raise_error(RuntimeError)
          expect(parent_record).not_to have_received(:save!)
        end

        it 'does not delete the pending relationships' do
          expect { perform }.to raise_error(RuntimeError)
          expect(IiifPrint::PendingRelationship.where(parent_id: parent_record.id).count).to eq(2)
        end
      end

      context 'when any child record is not found' do
        let(:child_record2) { nil }

        before do
          child_record1.save
        end

        it 'does not save the parent' do
          perform
          expect(parent_record).not_to have_received(:save!)
        end

        it 'reschedules the job' do
          perform
          expect(create_relationships_job).to have_received(:reschedule_job)
        end
      end
    end
  end
end
