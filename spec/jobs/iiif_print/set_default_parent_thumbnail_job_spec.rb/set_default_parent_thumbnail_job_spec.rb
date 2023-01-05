# frozen_string_literal: true

require 'spec_helper'

module IiifPrint
  RSpec.describe SetDefaultParentThumbnailJob, type: :job do
    subject(:set_default_parent_thumbnail_job) { described_class.new }

    # let(:importer) { double(Bulkrax::ImporterRun) }
    let(:importer_run) { double(Bulkrax::ImporterRun, id:3) }
    let(:importer_run_id) { importer_run.id }
    let(:parent_work) { create(:text) }
    let(:parent_work_with_file) { create(:text) }
    let(:child_work_1) { build(:text, title: ['Child work 1'], identifier: ['Child_Work_1']) }
    let(:child_work_2) { build(:text, title: ['Child work 2'], identifier: ['Child_Work_2']) }
    let(:file_set_1) { build(:file_set, title: ['File set 1']) }
    let(:file_set_2) { build(:file_set, title: ['File set 2']) }
    let(:file_set_3) { build(:file_set, title: ['File set 3']) }

    before do
      class GenericWork < ActiveFedora::Base
        include ::Hyrax::WorkBehavior
        include ::Hyrax::BasicMetadata

        # self.indexer = ::GenericWorkIndexer
      end

      module Bulkrax
        class ImporterRun < ApplicationRecord
          # belongs_to :importer
          # has_many :statuses, as: :runnable, dependent: :destroy
          # has_many :pending_relationships, dependent: :destroy
      
          def parents
            pending_relationships.pluck(:parent_id).uniq
          end
        end
      end
      # allow_any_instance_of(Bulkrax::ImporterRun).to receive(:last_run).and_return(double(Bulkrax::ImporterRun, id:3))
      # <Bulkrax::ImporterRun id: 3, importer_id: 1, total_work_entries: 2, enqueued_records: 0, processed_records: 2, deleted_records: 0, failed_records: 0, created_at: "2023-01-04 18:54:46", updated_at: "2023-01-04 18:54:47", processed_collections: 0, failed_collections: 0, total_collection_entries: 0, processed_relationships: 1, failed_relationships: 0, invalid_records: nil, processed_file_sets: 0, failed_file_sets: 0, total_file_set_entries: 0, processed_works: 2, failed_works: 0>
      allow(::Hyrax.config).to receive(:curation_concerns).and_return([GenericWork])
      allow(Bulkrax::ImporterRun).to receive(:find).with(importer_run_id).and_return(importer_run)

      allow(child_work_1).to receive(:file_sets).and_return([file_set_1])
      allow(child_work_2).to receive(:file_sets).and_return([file_set_2])
      allow(parent_work).to receive(:child_works).and_return([child_work_1, child_work_2])

      allow(parent_work_with_file).to receive(:thumbnail).and_return(file_set_3)
      allow(parent_work_with_file).to receive(:child_works).and_return([child_work_1, child_work_2])
    end

    describe '#perform' do
      context 'with a parent work' do
        it 'sets a thumbnail on the parent if there is not one already' do
          expect(importer_run).to receive(:increment!).with(:processed_parent_thumbnails)

          set_default_parent_thumbnail_job.perform(
            parent_work: parent_work,
            importer_run_id: importer_run_id
          )

          expect(parent_work.thumbnail).to eq(file_set_1)
          expect(parent_work.thumbnail).not_to eq(file_set_2)
          expect(parent_work.thumbnail).not_to eq(file_set_3)
        end

        it 'exits the job if the parent already has a thumbnail attached' do
          set_default_parent_thumbnail_job.perform(
            parent_work: parent_work_with_file,
            importer_run_id: importer_run_id
          )

          expect(parent_work_with_file.thumbnail).to eq(file_set_3)
          expect(parent_work_with_file.thumbnail).not_to eq(file_set_1)
          expect(parent_work_with_file.thumbnail).not_to eq(file_set_2)
        end
      end

      context 'without a parent work' do
        it 'returns an error' do
          expect(importer_run).to receive(:increment!).with(:failed_parent_thumbnails)

          set_default_parent_thumbnail_job.perform(
            parent_work: nil,
            importer_run_id: importer_run_id
          )
        end
      end
    end
  end
end
