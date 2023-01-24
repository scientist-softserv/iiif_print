require 'spec_helper'
require 'misc_shared'

RSpec.describe IiifPrint::Actors::IiifPrintUploadActor do
  let(:work_with_config) { WorkWithIiifPrintConfig.new(title: ['required title']) }
  let(:work_without_config) { WorkWithOutConfig.new(title: ['required title']) }
  let(:my_user) { build(:user) }
  let(:ability) { build(:ability) }
  let(:uploaded_pdf_file) { create(:uploaded_pdf_file) }
  let(:uploaded_txt_file) { create(:uploaded_txt_file) }
  let(:uploaded_file_ids) { [uploaded_pdf_file.id, uploaded_txt_file.id] }
  # duplicates logic from actor to find the path the job will expect
  let(:pdf_paths) do 
    uploads = Hyrax::UploadedFile.find(uploaded_file_ids)
    upload_paths = uploads.map { |upload| upload.file.file.file }
    upload_paths.select { |path| path.end_with?('.pdf', '.PDF') }
  end

  # attributes for environments
  let(:attributes) { { title: ['foo'], uploaded_files: uploaded_file_ids } }
  let(:no_pdf_attributes) { { title: ['foo'], uploaded_files: [] } }
  # environment with uploads:
  let(:with_pdf_env) { Hyrax::Actors::Environment.new(work, ability, attributes) }
  # environment with NO uploads:
  let(:edit_env) { Hyrax::Actors::Environment.new(work, ability, {}) }
  # environment with NO uploads:
  let(:no_pdf_env) { Hyrax::Actors::Environment.new(work, ability, no_pdf_attributes) }

  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  describe 'included in the actor stack' do
    let(:stack) { Hyrax::CurationConcern.actor_factory }
    it 'includes IiifPrint::UploadActor' do
      expect(stack.middlewares).to include(IiifPrint::Actors::IiifPrintUploadActor)
    end
  end

  context 'when work model includes IiifPrint' do
    let(:work) { work_with_config }
    describe ':create' do
      let(:mode) { :create }
      context 'when work has a pdf file' do
        let(:mode_env) { with_pdf_env }
        it 'queues IiifPrint::Jobs::ChildWorksFromPdfJob' do
          expect(IiifPrint::Jobs::ChildWorksFromPdfJob).to receive(:perform_later).with(
            work,
            pdf_paths,
            my_user,
            "admin_set/default",
            0
          )
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
      context 'when work has no pdf file' do
        let(:mode_env) { no_pdf_env }
        it 'does not queue job' do
          expect(IiifPrint::Jobs::ChildWorksFromPdfJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
    end

    describe ':update' do
      let(:mode) { :update }
      context 'work is updated with no additional uploads' do
        let(:mode_env) { edit_env }
        it 'does not queue job' do
          expect(IiifPrint::Jobs::ChildWorksFromPdfJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
      context 'work is updated with an additional PDF' do
        let(:mode_env) { with_pdf_env }
        it 'queues IiifPrint::Jobs::ChildWorksFromPdfJob' do
          expect(IiifPrint::Jobs::ChildWorksFromPdfJob).to receive(:perform_later).with(
            work,
            pdf_paths,
            my_user,
            "admin_set/default",
            0
          )
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
    end
  end

  context 'when work model does not use IiifPrint' do
    let(:work) { work_without_config }
    describe ':create' do
      let(:mode) { :create }
      context 'when work has a pdf file' do
        let(:mode_env) { with_pdf_env }
        it 'does not queue IiifPrint::Jobs::ChildWorksFromPdfJob' do
          expect(IiifPrint::Jobs::ChildWorksFromPdfJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
      context 'when work has no pdf file' do
        let(:mode_env) { no_pdf_env }
        it 'does not queue IiifPrint::Jobs::ChildWorksFromPdfJob' do
          expect(IiifPrint::Jobs::ChildWorksFromPdfJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
    end

    describe ':update' do
      let(:mode) { :update }
      context 'work is updated with no additional uploads' do
        let(:mode_env) { edit_env }
        it 'does not queue IiifPrint::Jobs::ChildWorksFromPdfJob' do
          expect(IiifPrint::Jobs::ChildWorksFromPdfJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
    end
  end
end
