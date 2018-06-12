require 'spec_helper'

# test NewspaperIssueIngest against a NewspaperIssue
RSpec.describe NewspaperWorks::Ingest::NewspaperIssueIngest do
  # define the path to the file we will use for multiple examples
  let(:path) do
    fixtures = File.join(NewspaperWorks::GEM_PATH, 'spec/fixtures/files')
    File.join(fixtures, 'sample-4page-issue.pdf')
  end

  it_behaves_like('ingest adapter IO')

  describe "file import and attachment" do
    it "ingests work and creates child page works" do
      adapter = build(:newspaper_issue_ingest)
      adapter.ingest(path)
      child_pages = adapter.work.members.select { |w| w.class == NewspaperPage }
      expect(child_pages.length).to eq 4
    end
  end
end
