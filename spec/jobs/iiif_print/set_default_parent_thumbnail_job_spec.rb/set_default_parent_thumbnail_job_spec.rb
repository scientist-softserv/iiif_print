# frozen_string_literal: true

require 'spec_helper'

module IiifPrint
  RSpec.describe SetDefaultParentThumbnailJob, type: :job do
    subject(:set_default_parent_thumbnail_job) { described_class.new }

    let(:importer_run) { double(Bulkrax::ImporterRun, id: 3) }
    let(:importer_run_id) { importer_run.id }
    let(:parent_work) { GenericWork.create(title: ['title']) }
    let(:parent_work_with_file) { GenericWork.create(title: ['title']) }
    let(:child_work_1) { GenericWork.new(title: ['Child work 1'], identifier: ['Child_Work_1']) }
    let(:child_work_2) { GenericWork.new(title: ['Child work 2'], identifier: ['Child_Work_2']) }
    let(:file_set_1) { FileSet.new(title: ['File set 1']) }
    let(:file_set_2) { FileSet.new(title: ['File set 2']) }
    let(:file_set_3) { FileSet.new(title: ['File set 3']) }

    before do
      class GenericWork < ActiveFedora::Base
        include ::Hyrax::WorkBehavior
        include ::Hyrax::BasicMetadata
      end

      module Bulkrax
        class ImporterRun < ApplicationRecord; end
      end
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
