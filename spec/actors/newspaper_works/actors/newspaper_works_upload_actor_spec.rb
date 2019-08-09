require 'faraday'
require 'spec_helper'
require 'misc_shared'

RSpec.describe NewspaperWorks::Actors::NewspaperWorksUploadActor, :perform_enqueued do
  include_context 'shared setup'

  let(:issue) { build(:newspaper_issue) }
  let(:ability) { build(:ability) }
  let(:uploaded_pdf_file) { create(:uploaded_pdf_file) }
  let(:uploaded_file_ids) { [uploaded_pdf_file.id] }
  let(:attributes) { { title: ['foo'], uploaded_files: uploaded_file_ids } }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  # environment with uploads:
  let(:env) { Hyrax::Actors::Environment.new(issue, ability, attributes) }
  # environment with NO uploads:
  let(:edit_env) { Hyrax::Actors::Environment.new(issue, ability, {}) }
  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  let(:uploaded_issue) do
    middleware.public_send(:create, env)
    # return work, reloaded, because env.curation_concern will be stale after
    #   running actor.
    NewspaperIssue.find(env.curation_concern.id)
  end

  let(:edited_issue) do
    middleware.public_send(:update, edit_env)
    NewspaperIssue.find(edit_env.curation_concern.id)
  end

  describe "NewspaperIssue upload of PDF" do
    do_now_jobs = [
      NewspaperWorks::CreateIssuePagesJob,
      IngestLocalFileJob,
      IngestJob
    ]

    # we over-burden one example, because sadly RSpec does not do well with
    #   shared state across examples (without use of `before(:all)` which is
    #   mutually exclusive with `let` in practice, and ruffles rubocop's
    #   overzealous sense of moral duty, speaking of which:
    it "creates child pages for issue", perform_enqueued: do_now_jobs do
      pages = uploaded_issue.ordered_pages
      expect(pages.size).to eq 2
      page = pages[0]
      # Page needs correct admin set:
      expect(page.admin_set_id).to eq 'admin_set/default'
      file_sets = page.members.select { |v| v.class == FileSet }
      expect(file_sets.size).to eq 1
      files = file_sets[0].files
      url = files[0].uri.to_s
      # fetch the thing from Fedora Commons:
      response = Faraday.get(url)
      stored_size = response.body.length
      expect(stored_size).to be > 0
      # expect that subsequent edits of same issue (run though update
      #   method of actor stack) do not duplicate pages (verify by count):
      expect(edited_issue.id).to eq uploaded_issue.id
      pages = edited_issue.ordered_pages
      expect(pages.size).to eq 2 # still the same page count
    end
  end
end
