require 'spec_helper'

RSpec.describe NewspaperWorks::IssuePDFComposer do
  let(:bare_issue) do
    build(:newspaper_issue)
  end

  let(:fixtures_path) do
    fixtures = File.join(NewspaperWorks::GEM_PATH, 'spec/fixtures/files')
    Hyrax.config.whitelisted_ingest_dirs.push(fixtures)
    fixtures
  end

  let(:pdf_path) do
    File.join(fixtures_path, 'minimal-1-page.pdf')
  end

  let(:broken_pdf) do
    File.join(fixtures_path, 'broken-truncated.pdf')
  end

  def page_with_pdf(name, path)
    # empty+saved fileset: only need id, no primary file, to attach derivatives
    fs = FileSet.create!
    page = NewspaperPage.create!(title: [name])
    page.members << fs
    page.save!
    derivatives = NewspaperWorks::Data::WorkDerivatives.of(page)
    derivatives.assign(path)
    derivatives.commit!
    page
  end

  let(:page1_with_pdf) { page_with_pdf('Page 1', pdf_path) }
  let(:page2_with_pdf) { page_with_pdf('Page 2', pdf_path) }

  let(:broken_page) { page_with_pdf('Broken Page', broken_pdf) }

  let(:two_page_issue) do
    issue = NewspaperIssue.create(title: ['Issue Test'])
    issue.ordered_members << page1_with_pdf
    issue.ordered_members << page2_with_pdf
    issue.save!
    issue
  end

  let(:unfinished_issue) do
    issue = NewspaperIssue.create(title: ['Unfinished issue'])
    issue.members << FileSet.create!
    issue.save!
    issue.ordered_members << broken_page
    issue.save!
    issue
  end

  describe "adapter construction" do
    it "constructs adapter" do
      composer = described_class.new(bare_issue)
      expect(composer.issue).to be bare_issue
      expect(composer.page_pdfs).to match_array []
    end
  end

  describe "Validation and handling of not-yet-ready pages" do
    it "validates PDFs" do
      # we can fake issue context with nil on construction to call validate_pdf
      composer = described_class.new(nil)
      expect(composer.validate_pdf(broken_pdf)).to be false
      expect(composer.validate_pdf(pdf_path)).to be true
    end

    it "raises NewspaperWorks::PagesNotReady on incomplete PDF" do
      composer = described_class.new(unfinished_issue)
      expect { composer.compose }.to raise_error(NewspaperWorks::PagesNotReady)
    end
  end

  describe "Construction, attachment of combined PDF" do
    do_now_jobs = [IngestLocalFileJob, IngestJob, InheritPermissionsJob]

    def files_of(work)
      NewspaperWorks::Data::WorkFiles.of(work)
    end

    it "creates issue PDF from sources", perform_enqueued: do_now_jobs do
      composer = described_class.new(two_page_issue)
      # no (primary) files attached to issue yet:
      expect(files_of(two_page_issue).keys.size).to eq 0
      # Make the mulit-page-pdf with IssuePDFComposer#compose:
      composer.compose
      # reload issue files, as they have been updated; check for PDF:
      two_page_issue.reload
      files = files_of(two_page_issue)
      expect(files.keys.size).to eq 1
      # getting path initiates a repository checkout of file:
      path = files.values[0].path
      # we found a PDF, simple check only extension (not validating):
      expect(path.end_with?('pdf')).to be true
    end
  end
end
