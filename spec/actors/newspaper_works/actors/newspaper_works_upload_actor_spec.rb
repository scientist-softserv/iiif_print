require 'faraday'
require 'spec_helper'

RSpec.describe NewspaperWorks::Actors::NewspaperWorksUploadActor, :perform_enqueued do
  let(:issue) { build(:newspaper_issue) }
  let(:ability) { build(:ability) }
  let(:uploaded_pdf_file) { create(:uploaded_pdf_file) }
  let(:uploaded_file_ids) { [uploaded_pdf_file.id] }
  let(:attributes) { { title: ['foo'], uploaded_files: uploaded_file_ids } }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:env) { Hyrax::Actors::Environment.new(issue, ability, attributes) }
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

  describe "NewspaperIssue upload of PDF" do
    # we over-burden one example, because sadly RSpec does not do well with
    #   shared state across examples (without use of `before(:all)` which is
    #   mutually exclusive with `let` in practice, and ruffles rubocop's
    #   overzealous sense of moral duty, speaking of which:
    # rubocop:disable RSpec/ExampleLength
    it "correctly creates child pages for issue" do
      pages = uploaded_issue.members.select { |w| w.class == NewspaperPage }
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
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
