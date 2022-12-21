require 'spec_helper'
<<<<<<< Updated upstream
require 'misc_shared'
=======
>>>>>>> Stashed changes

RSpec.describe IiifPrint::Actors::IiifPrintUploadActor do # , :perform_enqueued do
  let(:work) { build(:newspaper_issue) }
  let(:ability) { build(:ability) }
  let(:uploaded_pdf_file) { create(:uploaded_pdf_file) }
  let(:uploaded_txt_file) { create(:uploaded_txt_file) }
  let(:uploaded_file_ids) { [uploaded_pdf_file.id, uploaded_txt_file.id] }
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

  context 'when work model includes IiifPrintBehavior' do
    describe ':create' do
      let(:mode) { :create }
      before do
        allow(work).to receive(:respond_to?).and_call_original
        allow(work).to receive(:respond_to?).with(:split_pdf).and_return true
      end
      context 'when work has a pdf file' do
        let(:mode_env) { with_pdf_env }
        it 'queues a IiifPrint::CreatePagesJob' do
          expect(IiifPrint::CreatePagesJob).to receive(:perform_later).with(
            work,
            ["/app/samvera/hyrax-webapp/.internal_test_app/tmp/uploads/hyrax/uploaded_file/file/1/minimal-2-page.pdf"],
            "spaceballs@example.com",
            "admin_set/default"
          )
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
      context 'when work has no pdf file' do
        let(:mode_env) { no_pdf_env }
        it 'does not queue IiifPrint::CreatePagesJob' do
          expect(IiifPrint::CreatePagesJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
    end

    describe ':update' do
      let(:mode) { :update }
      before do
        allow(work).to receive(:respond_to?).and_call_original
        allow(work).to receive(:respond_to?).with(:split_pdf).and_return true
      end
      context 'works is updated with no additional uploads' do
        let(:mode_env) { edit_env }
        it 'queues a IiifPrint::CreatePagesJob' do
          expect(IiifPrint::CreatePagesJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
    end
  end

  context 'when work model does not IiifPrintBehavior' do
    describe ':create' do
      let(:mode) { :create }
      before do
        allow(work).to receive(:respond_to?).and_call_original
        allow(work).to receive(:respond_to?).with(:split_pdf).and_return false
      end
      context 'when work has a pdf file' do
        let(:mode_env) { with_pdf_env }
        it 'queues a IiifPrint::CreatePagesJob' do
          expect(IiifPrint::CreatePagesJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
      context 'when work has no pdf file' do
        let(:mode_env) { no_pdf_env }
        it 'does not queue IiifPrint::CreatePagesJob' do
          expect(IiifPrint::CreatePagesJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
    end

    describe ':update' do
      let(:mode) { :update }
      before do
        allow(work).to receive(:respond_to?).and_call_original
        allow(work).to receive(:respond_to?).with(:split_pdf).and_return false
      end
      context 'works is updated with no additional uploads' do
        let(:mode_env) { edit_env }
        it 'queues a IiifPrint::CreatePagesJob' do
          expect(IiifPrint::CreatePagesJob).not_to receive(:perform_later)
          expect(middleware.public_send(mode, mode_env)).to be true
        end
      end
    end
  end

  # let(:uploaded_work) do
  #   middleware.public_send(:create, env)
  #   # return work, reloaded, because env.curation_concern will be stale after
  #   #   running actor.
  #   NewspaperIssue.find(env.curation_concern.id)
  # end
  # let(:edited_work) do
  #   middleware.public_send(:update, edit_env)
  #   NewspaperIssue.find(edit_env.curation_concern.id)
  # end

  # describe "NewspaperIssue upload of PDF" do
  #   do_now_jobs = [
  #     IiifPrint::CreatePagesJob,
  #     IngestLocalFileJob,
  #     IngestJob
  #   ]

  #   # we over-burden one example, because sadly RSpec does not do well with
  #   #   shared state across examples (without use of `before(:all)` which is
  #   #   mutually exclusive with `let` in practice, and ruffles rubocop's
  #   #   overzealous sense of moral duty, speaking of which:
  #   xit "creates child pages for issue", perform_enqueued: do_now_jobs do
  #     pages = uploaded_issue.ordered_pages
  #     expect(pages.size).to eq 2
  #     page = pages[0]
  #     # Page needs correct admin set:
  #     expect(page.admin_set_id).to eq 'admin_set/default'
  #     file_sets = page.members.select { |v| v.class == FileSet }
  #     expect(file_sets.size).to eq 1
  #     files = file_sets[0].files
  #     url = files[0].uri.to_s
  #     # fetch the thing from Fedora Commons:
  #     response = Faraday.get(url)
  #     stored_size = response.body.length
  #     expect(stored_size).to be > 0
  #     # expect that subsequent edits of same issue (run though update
  #     #   method of actor stack) do not duplicate pages (verify by count):
  #     expect(edited_issue.id).to eq uploaded_issue.id
  #     pages = edited_issue.ordered_pages
  #     expect(pages.size).to eq 2 # still the same page count
  #   end
  # end
end
