# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IiifPrint::SplitPdfs::DestroyPdfChildWorksService do
  let(:subject) { described_class.conditionally_destroy_spawned_children_of(file_set: fileset, work: work) }

  let(:work) { WorkWithIiifPrintConfig.new(title: ['required title'], id: '123') }
  let(:fileset) { FileSet.new.tap { |fs| fs.save!(validate: false) } }
  let(:child_work) { WorkWithIiifPrintConfig.new(title: ["Child of #{work.id} file.pdf page 01"], id: '456', is_child: true) }
  let(:pending_rel1) do
    IiifPrint::PendingRelationship.new(
    parent_id: work.id,
    child_title: "Child of #{work.id} file.pdf page 01",
    child_order: "Child of #{work.id} file.pdf page 01",
    parent_model: WorkWithIiifPrintConfig,
    child_model: WorkWithIiifPrintConfig,
    file_id: fileset.id
  )
  end
  let(:pending_rel2) do
    IiifPrint::PendingRelationship.new(
    parent_id: work.id,
    child_title: "Child of #{work.id} another.pdf page 01",
    child_order: "Child of #{work.id} another.pdf page 01",
    parent_model: WorkWithIiifPrintConfig,
    child_model: WorkWithIiifPrintConfig,
    file_id: 'another'
  )
  end
  # let(:uploaded_pdf_file) { create(:uploaded_pdf_file) }
  # let(:uploaded_file_ids) { [uploaded_pdf_file.id] }

  before do
    allow(fileset).to receive(:parent).and_return(work)
    allow(fileset).to receive(:label).and_return('file.pdf')
    allow(fileset).to receive(:mime_type).and_return('application/pdf')
  end

  describe 'class' do
    subject { described_class }

    it { is_expected.to respond_to(:conditionally_destroy_spawned_children_of) }
    it { is_expected.not_to respond_to(:destroy_spawned_children) }
  end

  describe '#conditionally_destroy_spawned_children_of' do
    context 'with child works by fileset id' do
      before do
        allow(WorkWithIiifPrintConfig).to receive(:where).with(split_from_pdf_id: fileset.id).and_return([child_work])
      end

      it 'destroys the child works' do
        expect(child_work).to receive(:destroy)
        subject
      end
    end

    context 'with child works by title' do
      before do
        allow(WorkWithIiifPrintConfig).to receive(:where).with(split_from_pdf_id: fileset.id).and_return([])
        allow(WorkWithIiifPrintConfig).to receive(:where).and_return([child_work])
      end

      it 'destroys the child works' do
        expect(child_work).to receive(:destroy)
        subject
      end
    end

    context 'when fileset is not a PDF mimetype' do
      before do
        allow(fileset).to receive(:mime_type).and_return('not_pdf')
      end

      it 'returns with no changes' do
        expect(IiifPrint::PendingRelationship).not_to receive(:where)
      end
    end

    context 'when IiifPrint::PendingRelationship records exist' do
      before do
        pending_rel1.save
        pending_rel2.save
      end

      it 'deletes only records associated with the specific fileset PDF file' do
        expect { subject }.to change(IiifPrint::PendingRelationship, :count).by(-1)
      end
    end
  end
end
