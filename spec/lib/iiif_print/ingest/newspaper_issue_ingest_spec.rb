require 'spec_helper'

# test NewspaperIssueIngest against a NewspaperIssue
RSpec.describe IiifPrint::Ingest::NewspaperIssueIngest do
  # define the path to the file we will use for multiple examples
  let(:path) do
    fixtures = File.join(IiifPrint::GEM_PATH, 'spec/fixtures/files')
    Hyrax.config.whitelisted_ingest_dirs.push(fixtures)
    File.join(fixtures, 'sample-4page-issue.pdf')
  end

  let(:path2) do
    fixtures = File.join(IiifPrint::GEM_PATH, 'spec/fixtures/files')
    File.join(fixtures, 'ndnp-sample1.pdf')
  end

  it_behaves_like('ingest adapter IO')

  describe "file import and attachment" do
    do_now_jobs = [
      IngestJob,
      IngestLocalFileJob,
      InheritPermissionsJob,
      VisibilityCopyJob
    ]

    PERMISSION_METHODS = [
      :edit_users,
      :read_users,
      :discover_users,
      :edit_groups,
      :read_groups,
      :discover_groups
    ].freeze

    def check_equivalent_permissions(obj1, obj2)
      PERMISSION_METHODS.each do |m|
        expect(obj1.send(m)).to match_array obj2.send(m)
      end
      expect(obj1.visibility).to eq obj2.visibility
    end

    def check_page_metadata(page)
      expect(page.date_uploaded).not_to be nil
      expect(page.date_modified).not_to be nil
      # title: issue title plus page qualifier expected:
      expect(page.title).to contain_exactly "Here and There: Page 1"
      # page number is sequence number, expressed as String
      expect(page.page_number).to be_a String
      expect(page.page_number).to match(/^[0-9]+$/)
    end

    def assign_custom_permissions(work)
      # read_groups ['public'] <==> "open" visibility
      work.read_groups = ['public']
      # add a permission to issue, that is not default:
      work.read_users = ['peanutbutter@example.com']
      work.save!
    end

    it "ingests work and creates child page works" do
      adapter = build(:newspaper_issue_ingest)
      adapter.ingest(path)
      child_pages = adapter.work.members.select { |w| w.class == NewspaperPage }
      expect(child_pages.length).to eq 4
    end

    # For created child pages, date and permission attributes are side-effect
    #   of file attachment process (`IiifPrint::Data::WorkFiles`)
    #   manipulating the work through the Hyrax actor stack create pipeline.
    it "sets work attributes on created pages via file attachment",
       peform_enqueued: do_now_jobs do
      adapter = build(:newspaper_issue_ingest)
      assign_custom_permissions(adapter.work)
      adapter.ingest(path2)
      child_pages = adapter.work.members.select { |w| w.class == NewspaperPage }
      page = child_pages[0]
      check_page_metadata(page)
      # permissions:
      check_equivalent_permissions(adapter.work, page)
    end
  end
end
